# Single iOS Library for OAuth in popular social networks

## Installation

### Swift Package Manager

* File > Swift Packages > Add Package Dependency
* Add `https://github.com/NaUKMA-Programistich/OAFramework.git`

## Google

### Setup

* Get OAuth Client ID and URL https://console.cloud.google.com/

Example:

CLIENT_ID: **1234567890-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com**

URL: **com.googleusercontent.apps.1234567890-abcdefghijklmnopqrstuvwxyz**

* Add Google Client ID to Info.plist
```xml
    <key>GIDClientID</key>
    <string>CLIENT_ID</string>
```

* Add back URL to Schemes
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>URL</string>
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

## Facebook

### Setup

* Register application in https://developers.facebook.com/docs/facebook-login/ios/ by id

* Create application in https://developers.facebook.com/apps/creation/

* Add Client ID to Info.plist (APP-ID - our app id, APP-NAME - text in login CLIENT-TOKEN - )

Example:

CLIENT-TOKEN: **342747sgfghs342daqd**

APP-ID: **1052601802859530**

fbAPP-ID: **fb1052601802859530**

APP-NAME: **OAuthExample**

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
  <key>CFBundleURLSchemes</key>
  <array>
    <string>fbAPP-ID</string>
  </array>
  </dict>
</array>

<key>FacebookAppID</key>
<string>APP-ID</string>
<key>FacebookClientToken</key>
<string>CLIENT-TOKEN</string>
<key>FacebookDisplayName</key>
<string>APP-NAME</string>
```


### SwiftUI

* Call `FacebookOAuth.shared.handleLink(url: url)` in `openUrl`
* Call `FacebookOAuth.shared.startProcessSignIn` on action

```swift
import SwiftUI
import OAFramework

@main
struct OAuthExampleApp: App {
    var body: some Scene {
        WindowGroup {
            Button("Facebook Login") {
                FacebookOAuth.shared.startProcessSignIn { user, error in }
            }
            .padding()
            .onOpenURL(perform: { url in
                FacebookOAuth.shared.handleLink(url: url)
            })
        }
    }
}
```

### UIKIT

* Call `FacebookOAuth.shared.handleLink(url: url)` in AppDelegate by method `application:didFinishLaunchingWithOptions`
* Call `FacebookOAuth.shared.startProcessSignIn` on action


## Author
Dzhos Oleksii me@programistich.com
