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

In your code, add this line to initialize an OAuth object:

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
 
 If you listen for more than one provider, you may want to check `event.provider` that contains the provider's name. Moreover, `OAuth.popup` returns a `OAuthPopup` object which also dispatch the `OAuthEvent` specifically for this authorization:
 
 ```javascript
var fb_popup:OAuthPopup = oauth.popup("facebook");
fb_popup.addEventListener(OAuthEvent.ERROR, function(event:OAuthEvent):void {
	trace(event.error + " error:" + event.errorMessage);
});
fb_popup.addEventListener(OAuthEvent.TOKEN, function(event:OAuthEvent):void {
	trace("token " + event.accessToken + ", expires " + event.expires);
});
 ```


#### API Calls

You can also directly call APIs with the `OAuthHTTPService` class that wraps the default `HTTPService`. As the original one, you have two way to do these calls: either passing by mxml, or using only actionscript.

This class also add JSON encoding and decoding to the original `HTTPService` so you can set resultFormat to "json" and contentType to "application/json" if needed. 

 - Using MXML:

In `fx:Declarations` bloc, create your `OAuthHTTPService`:
 ```xml
<oauth:OAuthHTTPService
    id="fb_me" from="{fb_auth}" url="/me" resultFormat="json"
    result="resultHandler(event)"
    fault="faultHandler(event)" />
 ```
 
 To send the request:
 ```javascript
[Bindable] private var fb_auth:OAuthEvent = null;
oauth.addEventListener(OAuthEvent.TOKEN, function(event:OAuthEvent):void {
    fb_auth = event;
    fb_me.send();
});
oauth.popup("facebook", {authorize:{display:"touch"}});
 ```

 To handle the response:
 ```javascript
private function resultHandler(event:ResultEvent):void
{
    trace("From facebook, hello " + event.result.name);
}
private function faultHandler(event:FaultEvent):void
{
    trace('api request fail', event);
} 
 ```

 You can note the `from` property binded to the succeeded `OAuthEvent` which contains the tokens and description of the API calls authorization.


 - Using ActionScript only:

 ```javascript
oauth.addEventListener(OAuthEvent.TOKEN, function(event:OAuthEvent):void {
    var req:OAuthHTTPService = event.http(); // event.http() will create the OAuthHTTPService with from = event
    req.url = '/1.1/account/verify_credentials.json';
    req.resultFormat = 'json';
    req.addEventListener(FaultEvent.FAULT, faultHandler);
    req.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void {
        trace("From twitter, hello " + event.result.name);
    });
    req.send();
});
oauth.popup("twitter");
 ```

### Note

For OAuth 1 API requests, the request is proxified via https://oauth.io to sign your request without exposing your secret key. The OAuth 2 API requests are direct since we pass the request's authorizing description beside the tokens.

This library will try to access various URLs, so make sure to add

	<uses-permission android:name="android.permission.INTERNET"/>

in your android permissions ( in `<android><manifestAdditions>` in your app's xml config)