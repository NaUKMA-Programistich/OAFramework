# Single iOS Library for OAuth in popular social networks

## Google

Setup
----

* Get OAuth Client ID and URL https://console.cloud.google.com/

* Add Google Client ID to Info.plist
<key>GIDClientID</key>
<string>YOUR_IOS_CLIENT_ID</string>

* Add back URL to Schemes

Code
----

### SwiftUI

* Call GoogleOAuth.shared.handleLink(url: url) in openUrl
* Call GoogleOAuth.shared.startProcessSignIn on action

### UIKIT

* Call GoogleOAuth.shared.handleLink(url: url) in AppDelegate by method application:openURL:options
* Call GoogleOAuth.shared.startProcessSignIn on action

