import Foundation
import UIKit

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
 // Get root view controller
 */
func getRootViewController() -> UIViewController? {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let viewController = windowScene.windows.first?.rootViewController
    else { return nil }
    return viewController
}
