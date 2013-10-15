# OAuth.io ActionScript / Apache Flex Plugin

This is the official plugin for [OAuth.io](https://oauth.io) in [Apache Flex](http://flex.apache.org/) (formerly Adobe Flex)!

The OAuth.io plugin for Apache Flex allows you to use almost the same JavaScript code in your Flex application as you use in your web application, to connect any OAuth provider [available on OAuth.io](https://oauth.io/providers).

Lot of providers does not implement the _token_ response type, which typically lead developers to expose their secret keys. Using our unified interface, you always receive a token with a unique public key, and whatever the provider's implementation.


## OAuth.io Requirements and Set-Up

To use this plugin you will need to make sure you've registered your OAuth.io app and have a public key (https://oauth.io/docs).


### Installation

You can install this plugin into your project by downloading the latest zip from github or clone this repository.

Then, you can reference this library in your project or add it in your library path.

### Usage

The usage is basically the same than the web [javascript API](https://oauth.io/docs/api), but there are still some differences:

1. There is only the popup mode, as mobiles don't distinct redirection/popup.

2. Instead of sending callbacks in methods, we use the ActionScript coding style using classes & events. The `OAuth` object herits from `EventDispatcher` and can dispatch `OAuthEvent` objects, with types `OAuthEvent.TOKEN` and `OAuthEvent.ERROR`

In your Javascript, add this line to initialize OAuth:

	var oauth:OAuth = new OAuth("Public key");

To connect your user to a provider (e.g. facebook):

 ```javascript
oauth.addEventListener(OAuthEvent.ERROR, function(event:OAuthEvent):void {
	trace(event.error + " error:" + event.errorMessage);
});
oauth.addEventListener(OAuthEvent.TOKEN, function(event:OAuthEvent):void {
	trace("token " + event.accessToken + ", expires " + event.expires);
});
oauth.popup("facebook");
 ```


### Note

This library will try to access various URLs, so make sure to add

	<uses-permission android:name="android.permission.INTERNET"/>

in your android permissions ( in `<android><manifestAdditions>` in your app's xml config)