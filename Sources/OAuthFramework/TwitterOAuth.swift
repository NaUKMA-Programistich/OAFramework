import Foundation
import Logging
import AuthenticationServices

/**
 Typealias represent data for Twiter OAuth in callback
 - Parameters:
    - token: Github acess token if the authentication is successful, otherwise `nil`.
    - error: An `Error` object if there is an error during the authentication process, otherwise `nil`.
 */
public typealias TwitterOAuthInformation = (token: String?, error: Error?)

/**
 Typealias represent callback for Twitter OAuth
 - Parameters:
    - token: Github acess token if the authentication is successful, otherwise `nil`.
    - error: An `Error` object if there is an error during the authentication process, otherwise `nil`.
 */
public typealias TwitterOAuthCallback = (String?, Error?) -> Void

/**
 Typealias represent callback for Twitter temp data
 */
typealias TemporaryCredentials = (requestToken: String, requestTokenSecret: String)

public class TwitterOAuth: NSObject, ASWebAuthenticationPresentationContextProviding, OAuth {
    typealias CallBack = TwitterOAuthCallback
    typealias Information = TwitterOAuthInformation

    /// Shared instance of TwitterOAuth
    public static let shared = TwitterOAuth()

    /// Logger
    private let logger = Logger(label: "TwitterOAuth")

    /// Twitter API key obtained from Info.plist
    private let apiKey: String
    /// Twitter API key secret obtained from Info.plist
    private let apiKeySecret: String
    /// Twitter callback obtained from Info.plist
    private let callbackUrl: String
    /// Twitter redirect url obtained from Info.plist
    private var redirectUrl: String {
        return callbackUrl + "://"
    }

    /**
     Initializes the TwitterOAuth instance.
     */
    private override init() {
        guard let apiKey = checkInfoPlist(key: "TwitterApiKey") else {
            fatalError("TwitterApiKey does not exist")
        }
        self.apiKey = apiKey

        guard let apiKeySecret = checkInfoPlist(key: "TwitterApiKeySecret") else {
            fatalError("TwitterApiKeySecret does not exist")
        }
        self.apiKeySecret = apiKeySecret

        guard let callbackUrl = checkInfoPlist(key: "TwitterCallback") else {
            fatalError("TwitterCallback does not exist")
        }
        self.callbackUrl = callbackUrl
    }

    /**
     Entry point for initiating the sign-in process.
     - Parameters:
        - callback: The callback with TwitterOAuthCallback
     */
    public func startProcessSignIn(callback: @escaping TwitterOAuthCallback) {
        logger.info("#startProcessSignIn")
        getRequestToken { data in
            self.logger.info("Request Data: \(data)")
            let authURL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(data.requestToken)")!

            let authSession = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: self.callbackUrl
            ) { callbackURL, error in
                guard let callbackURL = callbackURL else { return }

                let items = URLComponents(string: callbackURL.absoluteString)?.queryItems
                guard let oauthToken = items?.first(where: { $0.name == "oauth_token" })?.value else { return }
                guard let oauthVerifier = items?.first(where: { $0.name == "oauth_verifier" })?.value else { return }

                self.logger.info("Token: \(oauthToken)")
                self.logger.info("Verifier: \(oauthVerifier)")

                self.getAccessToken(temporaryCredentials: data, verifier: oauthVerifier) { token in
                    self.logger.info("Access Token: \(token)")
                    callback(token, error)
                }
            }

            authSession.presentationContextProvider = self
            authSession.start()
        }
    }

    /**
     Handles deep links related to the sign-in process.
     - Parameter url: The URL received by the app to handle the deep link.
     */
    public func handleLink(url: URL) {
        logger.info("#handleLink")
        // Nothing to do
    }

    /**
     Logs out from the Twiter account
     */
    public func signOut() {
        logger.info("#signOut")
        // Nothing to do
    }

    /**
     Create ASPresentationAnchor for set presentationContextProvider
     */
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        var presentationAnchor: ASPresentationAnchor!
        if Thread.isMainThread {
            presentationAnchor = ASPresentationAnchor()
        } else {
            DispatchQueue.main.sync {
                presentationAnchor = ASPresentationAnchor()
            }
        }
        return presentationAnchor
    }
}

extension TwitterOAuth {
    /**
     - Parameter data: Twitter OAuth data
     */
    public static func displayInformationBy(data: TwitterOAuthInformation) {
        if let error = data.error {
            print("TwitterOAuth Error: \(error)")
            return
        }

        if let token = data.token {
            print("TwitterOAuth User Token: \(token)")
            return
        }
        print("TwitterOAuth Not Support Error")
    }
}

extension TwitterOAuth {

    /**
     Exchanges a temporary OAuth token and verifier for the final OAuth access token required for authenticating Twitter API requests.

     - Parameters:
        - temporaryCredentials: The temporary OAuth token and token secret obtained during the initial authentication process.
        - verifier: The OAuth verifier obtained during the user authorization step.
        - callback: A closure to be executed upon successful retrieval of the OAuth access token. The closure should take a `String` parameter representing the access token.
    */
    private func getAccessToken(
        temporaryCredentials: TemporaryCredentials,
        verifier: String,
        callback: @escaping (String) -> Void
    ) {
        self.logger.info("#getAccessToken")
        let request = (baseURLString: "https://api.twitter.com/oauth/access_token",
                       httpMethod: "POST",
                       consumerKey: self.apiKey,
                       consumerSecret: self.apiKeySecret)

        guard let baseURL = URL(string: request.baseURLString) else {
            self.logger.info("bad url")
            return
        }

        var parameters = [
            URLQueryItem(name: "oauth_token", value: temporaryCredentials.requestToken),
            URLQueryItem(name: "oauth_verifier", value: verifier),
            URLQueryItem(name: "oauth_consumer_key", value: request.consumerKey),
            URLQueryItem(name: "oauth_nonce", value: UUID().uuidString),
            URLQueryItem(name: "oauth_signature_method", value: "HMAC-SHA1"),
            URLQueryItem(name: "oauth_timestamp", value: String(Int(Date().timeIntervalSince1970))),
            URLQueryItem(name: "oauth_version", value: "1.0")
        ]

        let signature = oAuthSignature(
            httpMethod: request.httpMethod,
            baseURLString: request.baseURLString,
            parameters: parameters,
            consumerSecret: request.consumerSecret,
            oAuthTokenSecret: temporaryCredentials.requestTokenSecret
        )

        parameters.append(URLQueryItem(name: "oauth_signature", value: signature))

        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = request.httpMethod
        urlRequest.setValue(oAuthAuthorizationHeader(parameters: parameters), forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data,
                  let parameterString = String(data: data, encoding: .utf8),
                  let parameters = parameterString.urlQueryItems
            else {
                self.logger.info("bad response")
                return
            }

            guard let oauthToken = parameters.value(for: "oauth_token") else {
                self.logger.error("Error on get params")
                return
            }
            callback(oauthToken)
        }
        task.resume()
    }

    /**
     Requests a temporary OAuth token for initiating the Twitter authentication process.

     - Parameters:
        - callback: A closure to be executed upon successful retrieval of the temporary OAuth token. The closure should take a `TemporaryCredentials` object as its parameter.
    */
    private func getRequestToken(callback: @escaping (TemporaryCredentials) -> Void) {
        self.logger.info("#getRequestToken")
        let request = (baseURLString: "https://api.twitter.com/oauth/request_token",
                       httpMethod: "POST",
                       consumerKey: self.apiKey,
                       consumerSecret: self.apiKeySecret,
                       callbackURLString: self.redirectUrl)

        guard let baseURL = URL(string: request.baseURLString) else {
            self.logger.info("bad url")
            return
        }

        var parameters = [
            URLQueryItem(name: "oauth_callback", value: request.callbackURLString),
            URLQueryItem(name: "oauth_consumer_key", value: request.consumerKey),
            URLQueryItem(name: "oauth_nonce", value: UUID().uuidString),
            URLQueryItem(name: "oauth_signature_method", value: "HMAC-SHA1"),
            URLQueryItem(name: "oauth_timestamp", value: String(Int(Date().timeIntervalSince1970))),
            URLQueryItem(name: "oauth_version", value: "1.0")
        ]

        let signature = oAuthSignature(
            httpMethod: request.httpMethod,
            baseURLString: request.baseURLString,
            parameters: parameters,
            consumerSecret: request.consumerSecret
        )

        parameters.append(URLQueryItem(name: "oauth_signature", value: signature))

        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = request.httpMethod
        urlRequest.setValue(oAuthAuthorizationHeader(parameters: parameters), forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data,
                  let parameterString = String(data: data, encoding: .utf8),
                  let parameters = parameterString.urlQueryItems
            else {
                self.logger.info("bad response")
                return
            }

            guard
                let requestToken = parameters["oauth_token"],
                let requestTokenSecret = parameters["oauth_token_secret"]
            else {
                self.logger.error("Error on get params")
                return
            }
            callback(TemporaryCredentials(requestToken: requestToken, requestTokenSecret: requestTokenSecret))
        }
        task.resume()
    }

    /**
     Private function to generate the OAuth signature for OAuth 1.0a authentication.

     - Parameters:
       - httpMethod: The HTTP method used for the request (e.g., "GET" or "POST").
       - baseURLString: The base URL string of the request.
       - parameters: An array of URLQueryItem representing the OAuth parameters.
       - consumerSecret: The consumer secret used for authentication.
       - oAuthTokenSecret: The optional OAuth token secret, or `nil` if not available.

     - Returns: The OAuth signature as a string.
     */
    private func oAuthSignature(
        httpMethod: String,
        baseURLString: String,
        parameters: [URLQueryItem],
        consumerSecret: String,
        oAuthTokenSecret: String? = nil
    ) -> String {
        let signatureBaseString = oAuthSignatureBaseString(
            httpMethod: httpMethod,
            baseURLString: baseURLString,
            parameters: parameters
        )
        let signingKey = oAuthSigningKey(consumerSecret: consumerSecret, oAuthTokenSecret: oAuthTokenSecret)
        return signatureBaseString.hmacSHA1Hash(key: signingKey)
    }

    /**
     Private function to generate the OAuth signature base string for OAuth 1.0a authentication.

     - Parameters:
       - httpMethod: The HTTP method used for the request (e.g., "GET" or "POST").
       - baseURLString: The base URL string of the request.
       - parameters: An array of URLQueryItem representing the OAuth parameters.

     - Returns: The OAuth signature base string as a string.
     */
    private func oAuthSignatureBaseString(
        httpMethod: String,
        baseURLString: String,
        parameters: [URLQueryItem]
    ) -> String {
        var parameterComponents: [String] = []
        for parameter in parameters {
            let name = parameter.name.oAuthURLEncodedString
            let value = parameter.value?.oAuthURLEncodedString ?? ""
            parameterComponents.append("\(name)=\(value)")
        }
        let parameterString = parameterComponents.sorted().joined(separator: "&")
        return httpMethod + "&" +
            baseURLString.oAuthURLEncodedString + "&" +
            parameterString.oAuthURLEncodedString
    }


    /**
     Private function to generate the OAuth signing key used for OAuth 1.0a authentication.

     - Parameters:
       - consumerSecret: The consumer secret used for authentication.
       - oAuthTokenSecret: The optional OAuth token secret, or `nil` if not available.

     - Returns: The OAuth signing key as a string.
     */
    private func oAuthSigningKey(
        consumerSecret: String,
        oAuthTokenSecret: String?
    ) -> String {
        if let oAuthTokenSecret = oAuthTokenSecret {
            return consumerSecret.oAuthURLEncodedString + "&" +
                oAuthTokenSecret.oAuthURLEncodedString
        } else {
            return consumerSecret.oAuthURLEncodedString + "&"
        }
    }

    /**
     Private function to generate the OAuth authorization header string.

     - Parameters:
       - parameters: An array of URLQueryItem representing the OAuth parameters.

     - Returns: The OAuth authorization header as a string.
     */
    private func oAuthAuthorizationHeader(parameters: [URLQueryItem]) -> String {
        var parameterComponents: [String] = []
        for parameter in parameters {
            let name = parameter.name.oAuthURLEncodedString
            let value = parameter.value?.oAuthURLEncodedString ?? ""
            parameterComponents.append("\(name)=\"\(value)\"")
        }
        return "OAuth " + parameterComponents.sorted().joined(separator: ", ")
    }
}
