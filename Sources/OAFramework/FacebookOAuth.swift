import Foundation
import FacebookCore
import FacebookLogin
import Logging

/**
 Typealias representing the callback for Facebook OAuth.
 - Parameters:
    - result: Facebook result login process if successful, otherwise `nil`.
    - error: An `Error` object if there is an error during the authentication process, otherwise `nil`.
 */
public typealias FacebookOAuthCallback = (FBSDKLoginKit.LoginManagerLoginResult?, Error?) -> Void

/**
 Base class for Facebook OAuth.
 */
public class FacebookOAuth: SignIn {

    private let loginManager = LoginManager()

    /// Shared instance of FacebookOAuth
    public static let shared = FacebookOAuth()

    private let logger = Logger(label: "FacebookOAuth")

    /**
     Initializes the FacebookOAuth instance.
     */
    private init() {
        // Setup handle
        ApplicationDelegate.shared.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)

        // Check Info.plist keys
        guard checkInfoPlist(key: "FacebookAppID") != nil else {
            logger.error("FacebookAppID does not exist")
            return
        }
        guard checkInfoPlist(key: "FacebookClientToken") != nil else {
            logger.error("FacebookClientToken does not exist")
            return
        }
        guard checkInfoPlist(key: "FacebookDisplayName") != nil else {
            logger.error("FacebookDisplayName does not exist")
            return
        }
    }

    /**
     Entry point for initiating the sign-in process.
     - Parameter callback: The callback with FacebookOAuthCallback
     */
    public func startProcessSignIn(callback: @escaping FacebookOAuthCallback) {
        logger.info("#startProcessSignIn")
        guard let viewController = getRootViewController() else { return }
        loginManager.logIn(permissions: ["public_profile"], from: viewController, handler: callback)
    }

    /**
     Handles deep links related to the Facebook sign-in process.
     - Parameter url: The URL received by the app to handle the deep link.
     */
    public func handleLink(url: URL) {
        logger.info("#handleLink")
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: UIApplication.OpenURLOptionsKey.annotation
        )
    }

    /**
     Logs out from the local Facebook account.
     */
    public func signOut() {
        logger.info("#signOut")
        loginManager.logOut()
    }
}
