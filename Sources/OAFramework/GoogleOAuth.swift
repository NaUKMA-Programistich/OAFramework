import Foundation
import GoogleSignIn
import Logging

/**
 Typealias represent callback for Google OAuth
 - Parameters:
    - user: Google user object if the authentication is successful, otherwise `nil`.
    - error: An `Error` object if there is an error during the authentication process, otherwise `nil`.
 */
public typealias GoogleOAuthCallback = (GIDGoogleUser?, Error?) -> Void

/**
 Base class for Google OAuth
 */
public class GoogleOAuth: SignIn {

    private let logger = Logger(label: "GoogleOAuth")

    /// Shared instance of GoogleOAuth
    public static let shared = GoogleOAuth()

    /// Google client ID obtained from Info.plist. Obtain from https://console.cloud.google.com/
    private let clientID: String

    /**
     Initializes the GoogleOAuth instance.
     */
    private init() {
        // Check if client ID exists in Info.plist
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
           let infoDict = NSDictionary(contentsOfFile: path),
           let gidClientID = infoDict["GIDClientID"] as? String {
            logger.info("Google client ID: \(gidClientID)")
            self.clientID = gidClientID
        } else {
            logger.info("Google client ID does not exist")
            self.clientID = ""
        }
        // Check URL deeplink setup (hidden in GoogleSignIn library)
    }

    /**
     Entry point for initiating the sign-in process.
     - Parameters:
        - callback: The callback with GoogleOAuthCallback
     */
    public func startProcessSignIn(callback: @escaping GoogleOAuthCallback) {
        logger.info("#startProcessSignIn")

        // If there is a previous sign-in, attempt to restore it
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            logger.info("hasPreviousSignIn")
            GIDSignIn.sharedInstance.restorePreviousSignIn(callback: callback)
            return
        }

        // Get the window scene and root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let viewController = windowScene.windows.first?.rootViewController else { return }

        // Configure GIDSignIn and initiate the sign-in process
        let configuration = GIDConfiguration(clientID: clientID)
        logger.info("signIn")
        GIDSignIn.sharedInstance.signIn(with: configuration, presenting: viewController, callback: callback)
    }

    /**
     Handles deep links related to the sign-in process.
     - Parameter url: The URL received by the app to handle the deep link.
     */
    public func handleLink(url: URL) {
        logger.info("#handleLink")
        GIDSignIn.sharedInstance.handle(url)
    }

    /**
     Logs out from the local Google account.
     */
    public func signOut() {
        logger.info("#signOut")
        GIDSignIn.sharedInstance.signOut()
    }
}

/// Protocol indicating conformance to sign-in functionality.
protocol SignIn {

}
