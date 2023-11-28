# Single iOS Library for OAuth in popular social networks

## Installation

### Swift Package Manager

* File > Swift Packages > Add Package Dependency
* Add `https://github.com/NaUKMA-Programistich/OAFramework.git`

## Google

### Setup

* Get OAuth Client ID and URL https://console.cloud.google.com/

Example:
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
* Call `GoogleOAuth.shared.displayInformationBy` for display result login

```swift
@main
struct OAuthExampleApp: App {
    var body: some Scene {
        WindowGroup {
            Button("Google Login") {
                GoogleOAuth.shared.startProcessSignIn { user, error in
                    GoogleOAuth.displayInformationBy(data: (user, error))
                }
            }
            .padding()
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
* Call `FacebookOAuth.shared.displayInformationBy` for display result login

```swift
import SwiftUI
import OAFramework

@main
struct OAuthExampleApp: App {
    var body: some Scene {
        WindowGroup {
            Button("Facebook Login") {
                FacebookOAuth.shared.startProcessSignIn { result, error in
                    FacebookOAuth.displayInformationBy(data: (result, error))
                }
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

## Github

### Setup
* Register app in https://github.com/settings/developers#oauth-apps
* Add client id, secret token, callback url to Info.Plist

Example:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
  <key>CFBundleURLSchemes</key>
  <array>
    <string>CALLBACK</string>
  </array>
  </dict>
</array>

<key>GithubClientId</key>
<string>CLIENT-ID</string>
<key>GithubSecretToken</key>
<string>SECRET-TOKEN</string>
<key>GithubCallback</key>
<string>CALLBACK</string>
```

### SwiftUI

* Call `GithubOAuth.shared.startProcessSignIn` on action
* Call `GithubOAuth.shared.displayInformationBy` for display result login

```swift
import SwiftUI
import OAFramework

@main
struct OAuthExampleApp: App {
    var body: some Scene {
        WindowGroup {
            Button("Github Login") {
                GithubOAuth.shared.startProcessSignIn { token, error in
                    GithubOAuth.displayInformationBy(data: (token, error))
                }
            }
            .padding()
        }
    }
}
```

### UIKIT

* Call `GithubOAuth.shared.startProcessSignIn` on action


## Twitter

### Setup
* Register app in https://developer.twitter.com/en/portal/projects-and-apps
* Add api key, api key secret, client id, secret token, callback url to Info.Plist

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
  <key>CFBundleURLSchemes</key>
  <array>
    <string>CALLBACK</string>
  </array>
  </dict>
</array>

<key>TwitterApiKey</key>
<string>API-KEY</string>
<key>TwitterApiKeySecret</key>
<string>API-KEY-SECRET</string>
<key>TwitterCallback</key>
<string>CALLBACK</string>
```

## SwiftUI


```swift
import SwiftUI
import OAFramework

@main
struct OAuthExampleApp: App {
    var body: some Scene {
        WindowGroup {
            Button("Twitter Login") {
                TwitterOAuth.shared.startProcessSignIn { token, error in
                    TwitterOAuth.displayInformationBy(data: (token, error))
                }
            }
            .padding()
        }
    }
}
```

### UIKIT

* Call `TwitterOAuth.shared.startProcessSignIn` on action

## Author
Dzhos Oleksii me@programistich.com
