import Foundation
import Logging
import AuthenticationServices

/**
 Typealias represent data for Github OAuth in callback
 - Parameters:
    - token: Github acess token if the authentication is successful, otherwise `nil`.
    - error: An `Error` object if there is an error during the authentication process, otherwise `nil`.
 */
public typealias GithubOAuthInformation = (token: String?, error: Error?)

/**
 Typealias represent callback for Github OAuth
 - Parameters:
    - token: Github acess token if the authentication is successful, otherwise `nil`.
    - error: An `Error` object if there is an error during the authentication process, otherwise `nil`.
 */
public typealias GithubOAuthCallback = (String?, Error?) -> Void

/**
 Base class for Github OAuth
 */
public class GithubOAuth: NSObject, ASWebAuthenticationPresentationContextProviding, OAuth {
    typealias CallBack = GithubOAuthCallback
    typealias Information = GithubOAuthInformation

    private let logger = Logger(label: "GithubOAuth")

    /// Shared instance of GithubOAuth https://github.com/settings/developers#oauth-apps
    public static let shared = GithubOAuth()

    /// Github client ID obtained from Info.plist
    private let clientID: String
    /// Github secret token obtained from Info.plist
    private let secretToken: String
    /// Github callback obtained from Info.plist without ://
    private let callbackUrl: String

    /// Github redirect with slashes
    private var redirectUrl: String {
        return callbackUrl + "://"
    }

    /**
     Initializes the GithubOAuth instance.
     */
    private override init() {
        guard let clientId = checkInfoPlist(key: "GithubClientId") else {
            fatalError("GithubClientId does not exist")
        }
        guard let secretToken = checkInfoPlist(key: "GithubSecretToken") else {
            fatalError("GithubRedirectUrl does not exist")
        }
        guard let callbackUrl = checkInfoPlist(key: "GithubCallback") else {
            fatalError("GithubSecretToken does not exist")
        }

        self.clientID = clientId
        self.callbackUrl = callbackUrl
        self.secretToken = secretToken
    }

    /**
     Entry point for initiating the sign-in process.
     - Parameters:
        - callback: The callback with GithubOAuthCallback
     */
    public func startProcessSignIn(callback: @escaping GithubOAuthCallback) {
        logger.info("#startProcessSignIn")

        let baseUrl = "https://github.com/login/oauth/authorize?"
        let queryUrl = "client_id=\(self.clientID)&redirect_uri=\(self.redirectUrl)&scope=user"
        let authURLString = baseUrl + queryUrl

        let authURL = URL(string: authURLString)!

        let authSession = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: self.callbackUrl
        ) { callbackURL, error in
            if let callbackURL = callbackURL {
                let code = URLComponents(string: callbackURL.absoluteString)?
                    .queryItems?
                    .first(where: { $0.name == "code" })?
                    .value
                if let code = code {
                    self.logger.info("code \(code)")
                    self.processGetAccessToken(code: code, callback: callback)
                } else {
                    callback(nil, nil)
                }
            } else {
                callback(nil, error)
            }
        }

        authSession.presentationContextProvider = self
        authSession.start()
    }

    /**
     Getting access token from github
     - Parameters:
        - code: Code from GET auth
        - callback: The callback with GithubOAuthCallback
     */
    private func processGetAccessToken(code: String, callback: @escaping GithubOAuthCallback) {
        logger.info("#processGetAccessToken")

        let tokenEndpointURL = URL(string: "https://github.com/login/oauth/access_token")!
        let requestBody = [
            "client_id": self.clientID,
            "client_secret": self.secretToken,
            "code": code,
            "redirect_uri": self.redirectUrl
        ]

        var request = URLRequest(url: tokenEndpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            callback(nil, error)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                callback(nil, error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                    (200..<300).contains(httpResponse.statusCode),
                  let data = data
            else {
                callback(nil, (NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                return
            }

            let jsonString = String(data: data, encoding: .utf8)
            let parts = jsonString?.split(separator: "&")
            let tokenPart = parts?.first { $0.starts(with: "access_token") }
            if let accessToken = tokenPart?.split(separator: "=")[1] {
                callback(String(accessToken), nil)
            } else {
                callback(nil, (NSError(domain: "Not found access token", code: 0, userInfo: nil)))
            }
        }
        task.resume()
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
     Logs out from the local Github account.
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

public extension GithubOAuth {
    /**
     - Parameter data: Github OAuth data
     */
    static func displayInformationBy(data: GithubOAuthInformation) {
        if let error = data.error {
            print("GithubOAuth Error: \(error)")
            return
        }

        if let token = data.token {
            print("GithubOAuth User Token: \(token)")
            return
        }
        print("GithubOAuth Not Support Error")
    }
}
