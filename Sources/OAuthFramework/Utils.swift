import Foundation
import UIKit
import CommonCrypto

/**
 A utility function to check the value of a specified key in the Info.plist file.

 - Parameter key: The key in Info.plist whose value needs to be checked.
 - Returns: The value associated with the given key in Info.plist, or `nil` if not found.
 */
func checkInfoPlist(key: String) -> String? {
    if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
       let infoDict = NSDictionary(contentsOfFile: path),
       let value = infoDict[key] as? String {
        return value
    } else {
        return nil
    }
}

/**
 A utility function to get the root view controller of the main window.

 - Returns: The root view controller of the main window, or `nil` if not found.
 */
func getRootViewController() -> UIViewController? {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let viewController = windowScene.windows.first?.rootViewController
    else { return nil }
    return viewController
}

extension String {
    /**
     Computes the HMAC-SHA1 hash of the string using the provided key.

     - Parameter key: The key used for HMAC-SHA1 hashing.
     - Returns: The HMAC-SHA1 hash of the string.
     */
    func hmacSHA1Hash(key: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1),
               key,
               key.count,
               self,
               self.count,
               &digest)
        return Data(digest).base64EncodedString()
    }
}

extension CharacterSet {
    /**
     Returns a character set with the characters allowed in the URL according to RFC3986.

     - Returns: The character set allowed in the URL according to RFC3986.
     */
    static var urlRFC3986Allowed: CharacterSet {
        CharacterSet(charactersIn: "-_.~").union(.alphanumerics)
    }
}

extension String {
    /**
     Returns an OAuth URL encoded version of the string.

     - Returns: The OAuth URL encoded string.
     */
    var oAuthURLEncodedString: String {
        self.addingPercentEncoding(withAllowedCharacters: .urlRFC3986Allowed) ?? self
    }
}

extension String {
    /**
     Parses the string as a URL and returns its query items.

     - Returns: An array of URLQueryItem representing the query parameters, or `nil` if parsing fails.
     */
    var urlQueryItems: [URLQueryItem]? {
        URLComponents(string: "://?\(self)")?.queryItems
    }
}

extension Array where Element == URLQueryItem {
    /**
     Retrieves the value associated with a specific query parameter name.

     - Parameter name: The name of the query parameter.
     - Returns: The value associated with the specified query parameter name, or `nil` if not found.
     */
    func value(for name: String) -> String? {
        return self.filter({$0.name == name}).first?.value
    }

    /**
     Subscript to retrieve the value associated with a specific query parameter name.

     - Parameter name: The name of the query parameter.
     - Returns: The value associated with the specified query parameter name, or `nil` if not found.
     */
    subscript(name: String) -> String? {
        return value(for: name)
    }
}
