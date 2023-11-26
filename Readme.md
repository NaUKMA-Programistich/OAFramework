# Single iOS Library for OAuth in popular social networks

## Installation

### Swift Package Manager

* File > Swift Packages > Add Package Dependency
* Add `https://github.com/NaUKMA-Programistich/OAFramework.git`

## Google

### Setup

* Get OAuth Client ID and URL https://console.cloud.google.com/

Example:

Client ID: **1234567890-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com**

URL: **com.googleusercontent.apps.1234567890-abcdefghijklmnopqrstuvwxyz**

* Add Google Client ID to Info.plist
```xml
    <key>GIDClientID</key>
    <string>YOUR_IOS_CLIENT_ID</string>
```

* Add back URL to Schemes
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>YOUR_DOT_REVERSED_IOS_CLIENT_ID</string>
    </array>
  </dict>
</array>

```

### SwiftUI

* Call `GoogleOAuth.shared.handleLink(url: url)` in `openUrl`
* Call `GoogleOAuth.shared.startProcessSignIn` on action

```swift
@main
struct OAuthExampleApp: App {
    var body: some Scene {
        WindowGroup {
            Button("Google Login") {
                GoogleOAuth.shared.startProcessSignIn { user, error in }
            }
            .onOpenURL(perform: { url in
                GoogleOAuth.shared.handleLink(url: url)
            })
        }
    }
}
```

### UIKIT

* Call `GoogleOAuth.shared.handleLink(url: url)` in AppDelegate by method `application:openURL:options`
* Call `GoogleOAuth.shared.startProcessSignIn` on action

## Author
Dzhos Oleksii me@programistich.com
