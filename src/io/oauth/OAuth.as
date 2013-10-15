package io.oauth
{
	import flash.display.Stage;
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.LocationChangeEvent;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	
	import mx.core.FlexGlobals;
	
	[Event(name="OAuthError", type="io.oauth.OAuthEvent")]
	[Event(name="OAuthToken", type="io.oauth.OAuthEvent")]

	public class OAuth extends EventDispatcher
	{
		protected var oauthd_url:String = "https://oauth.io/auth";

		private var publicKey:String;		
		private var clientStates:Array;
		
		private var webview:StageWebView;
		
		public function OAuth(publicKey:String = null) {
			this.publicKey = publicKey;
			this.clientStates = new Array();
		}
		
		public function initialize(publicKey:String) : void {
			this.publicKey = publicKey;
		} 

		public function popup(provider:String, options:Object = null) : void {
			if ( ! this.publicKey)
			{
				this.error("OAuth object must be initialized",provider);
				return;
			}
			if ( ! options)
				options = new Object();
			if ( options.webview )
				this.webview = options.webview;
			else {
				var stage:Stage = options.stage || FlexGlobals.topLevelApplication.stage;
				this.webview = new StageWebView();
				this.webview.viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
				this.webview.stage = stage;
			}
			delete options.webview;
			options.state = "TODO";
			options.state_type = "client";
			this.clientStates.push(options.state);
			
			var url:String = this.oauthd_url + '/' + provider + "?k=" + this.publicKey;
			url += '&redirect_uri=http%3A%2F%2Flocalhost';
			url += "&opts=" + encodeURIComponent(JSON.stringify(options));

			this.webview.addEventListener(LocationChangeEvent.LOCATION_CHANGING, onLocationChange);
			this.webview.addEventListener(LocationChangeEvent.LOCATION_CHANGE, onLocationChange);
			this.webview.addEventListener(ErrorEvent.ERROR, onWebviewError);
			this.webview.loadURL(url);
			
			function onLocationChange(locationChangeEvent:LocationChangeEvent):void
			{
				var loc:String = locationChangeEvent.location;
				if (loc.substr(0,17) != "http://localhost/")
					return;
				var oauthio_pattern:RegExp = /[\\#&]oauthio=([^&]*)/;
				var results:Array = loc.match(oauthio_pattern);
				webview.stage = null;
				webview.dispose();
				if (results && results[1]) {
					var event:OAuthEvent = new OAuthEvent(OAuthEvent.TOKEN);
					event.data = decodeURIComponent(results[1].replace(/\+/g, " "));
					if (event.error) // todo: find a better way to retype event
					{
						error(event.errorMessage, provider, event.error);
						return;
					}
					event.provider = provider;
					dispatchEvent(event);
				}
				else
					error("unable to receive token", provider);
			}
			
			function onWebviewError(event:ErrorEvent):void
			{
				error(event.toString(), provider, "StageWebView");
			}
		}
		
		private function error(message:String, provider:String, error:String="unknown"):void
		{
			var event:OAuthEvent = new OAuthEvent(OAuthEvent.ERROR);
			event.error = error;
			event.errorMessage = message;
			event.provider = provider;
			this.dispatchEvent(event);
		}
	}
}