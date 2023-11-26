import Foundation
import GoogleSignIn
import Logging

/**
 Simple typealias for process result
 */
public typealias GoogleOAuthCallback = (GIDGoogleUser?, Error?) -> Void

/**
    Base class for auth in Google Account
 */
public class GoogleOAuth: SignIn {
    private let logger = Logger(label: "GoogleOAuth")

    public static let shared = GoogleOAuth()

    /**
     Google client ID setup from Info.plist and get from https://console.cloud.google.com/
     */
    private let clientID: String

    /**
     Constructor with check exist client id
     */
    private init() {
        // Check client ID exist
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"), let infoDict = NSDictionary(contentsOfFile: path), let gidClientID = infoDict["GIDClientID"] as? String {
            logger.info("Google client ID: \(gidClientID)")
            self.clientID =  gidClientID
        } else {
            logger.info("Google client ID not exist")
            self.clientID = ""
        }
        // Check URL deeplink setup hiden in GoogleSignIn library
    }

    /**
     Entry point for login
     */
    public func startProcessSignIn(callback: @escaping GoogleOAuthCallback) {
        logger.info("#startProcessSignIn")
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            logger.info("hasPreviousSignIn")
            GIDSignIn.sharedInstance.restorePreviousSignIn(callback: callback)
            return
        }
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let viewController = windowScene.windows.first?.rootViewController else { return }
        let configuration = GIDConfiguration(clientID: clientID)

        logger.info("signIn")
        GIDSignIn.sharedInstance.signIn(with: configuration, presenting: viewController, callback: callback)
    }

    /**
     Handle deeplink
     */
    public func handleLink(url: URL) {
        logger.info("#handleLink")
        GIDSignIn.sharedInstance.handle(url)
    }


    /**
     Log out from local Google
     */
    public func signOut() {
        logger.info("#signOut")
        GIDSignIn.sharedInstance.signOut()
    }
}

protocol SignIn {

}
