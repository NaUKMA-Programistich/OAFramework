import Foundation
import FacebookCore
import FacebookLogin
import Logging

/**
 Typealias representing the data in callback for Facebook OAuth.
 - Parameters:
    - result: Facebook result login process if successful, otherwise `nil`.
    - error: An `Error` object if there is an error during the authentication process, otherwise `nil`.
 */
public typealias FacebookOAuthInformation = (result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?)

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
            fatalError("FacebookAppID does not exist")
        }
        guard checkInfoPlist(key: "FacebookClientToken") != nil else {
            fatalError("FacebookClientToken does not exist")
        }
        guard checkInfoPlist(key: "FacebookDisplayName") != nil else {
            fatalError("FacebookDisplayName does not exist")
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

public extension FacebookOAuth {
    /**
     - Parameter data: FacebookOAuth OAuth data
     */
    static func displayInformationBy(data: FacebookOAuthInformation) {
        if let error = data.error {
            print("FacebookOAuth Error: \(error)")
            return
        }

        if let result = data.result, let token = result.token?.tokenString {
            print("FacebookOAuth User Token: \(token)")
            return
        }

        print("FacebookOAuth Not Support Error")
    }
}
