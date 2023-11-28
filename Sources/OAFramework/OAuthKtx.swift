import Foundation

/// Protocol indicating conformance to sign-in functionality.
protocol OAuth<CallBack, Information> {
    associatedtype CallBack
    associatedtype Information

    func startProcessSignIn(callback: CallBack)
    func handleLink(url: URL)
    func signOut()

    static func displayInformationBy(data: Information)
}
