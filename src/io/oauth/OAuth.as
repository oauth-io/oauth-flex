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


	/**
	 * <p>The io.oauth.OAuth class it the main class from io.oauth:</p>
	 *
	 * <p>You can start an authorization process to a provider once
	 * initialized with OAuth.popup</p>
	 *
	 * <p>To see the documentation of this library, please see
	 * <a href="https://github.com/oauth-io/oauth-flex">https://github.com/oauth-io/oauth-flex</a></p>
	 */
	public class OAuth extends EventDispatcher
	{
		/**
		 *  OAuth daemon url to use. By default, this is set to <code>https://oauth.io</code>
		 */
		public var oauthd_url:String;

		public var publicKey:String;
		private var clientStates:Array;

		private var webview:StageWebView;

		/**
		 *  Create the OAuth object and initialize it to the public key passed in parameter.
		 *
		 *  @param publicKey The public key of oauthd / oauth.io to use
		 */
		public function OAuth(publicKey:String = null) {
			this.publicKey = publicKey;
			this.clientStates = new Array();
			this.oauthd_url = "https://oauth.io";
		}

		/**
		 *  Set the oauthd public key to use.
		 *
		 *  @param publicKey The public key of oauthd / oauth.io to use
		 */
		public function initialize(publicKey:String) : void {
			this.publicKey = publicKey;
		}

		/**
		 *  Set the oauth daemon's url to use.
		 *  By default, this uses https://oauth.io
		 *
		 *  @param url The daemon url to use
		 */
		public function setOAuthdURL(url:String) : void {
			this.oauthd_url = url;
		}

		/**
		 *  Opens a full screen webview and redirect it to the provider's authorization form.
		 *  Once authorized/rejected, the OAuthEvent.TOKEN or OAuthEvent.ERROR event is dispatched.
		 *
		 *  @param provider The provider's name. e.g. facebook, google, twitter...
		 *
		 *  @param options The options can contain an <code>authorize</code> object with additional
		 *  parameters for the authorization url.
		 */
		public function popup(provider:String, options:Object = null) : OAuthPopup {
			var self:OAuth = this;
			var _popup:OAuthPopup = new OAuthPopup();
			var e:OAuthEvent;

			if ( ! this.publicKey)
			{
				e = error("OAuth object must be initialized",provider);
				this.dispatchEvent(e);
				_popup.dispatchEvent(e);
				return _popup;
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

			var url:String = this.oauthd_url + "/auth/" + provider + "?k=" + this.publicKey;
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
					event.oauth = self;
					event.parseData(decodeURIComponent(results[1].replace(/\+/g, " ")));
					if (event.error) // todo: find a better way to retype event
					{
						e = error(event.errorMessage, provider, event.error);
						dispatchEvent(e);
						_popup.dispatchEvent(e);
						return;
					}
					event.provider = provider;
					dispatchEvent(event);
					_popup.dispatchEvent(event);
				}
				else {
					e = error("unable to receive token", provider);
					dispatchEvent(e);
					_popup.dispatchEvent(e);
				}
			}

			function onWebviewError(event:ErrorEvent):void
			{
				e = error(event.toString(), provider, "StageWebView");
				this.dispatchEvent(e);
				_popup.dispatchEvent(e);
			}

			return _popup;
		}

		private function error(message:String, provider:String, error:String="unknown"):OAuthEvent
		{
			var event:OAuthEvent = new OAuthEvent(OAuthEvent.ERROR);
			event.error = error;
			event.errorMessage = message;
			event.provider = provider;
			return event;
		}
	}
}