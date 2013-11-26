package io.oauth
{
	import flash.events.Event;
	
	/**
	 * The io.oauth.OAuthEvent contains a response from an authorization,
	 * weather it has succeeded or not. It can also create an io.oauth.OAuthHTTPService
	 * from the received tokens to request authorized api calls.
	 */
	public class OAuthEvent extends Event
	{
		/**
		 *  This event is dispatched when an error occurs
		 */
		public static const ERROR:String = "OAuthError";
		
		/**
		 *  This event is dispatched once you receive a token
		 */
		public static const TOKEN:String = "OAuthToken";
		
		/**
		 *  Reference to the io.oauth.OAuth class that created this object.
		 */
		public var oauth:OAuth;
		
		private var _error:String;
		private var _errorMessage:String;
		
		private var _provider:String;
		private var _accessToken:String;
		private var _accessTokenSecret:String;
		private var _expires:Number;
		private var _data:Object;
		private var _state:String;
		private var _request:Object;
		private var _requestData:Object;
		
		/**
		 *  Create an oauth event
		 */
		public function OAuthEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		/**
		 *  Contains the error id
		 */
		public function get error():String
		{
			return this._error;
		}
		public function set error(error:String):void
		{
			this._error = error;
		}
		
		/**
		 *  Contains the error message
		 */
		public function get errorMessage():String
		{
			return this._errorMessage;
		}
		public function set errorMessage(errorMessage:String):void
		{
			this._errorMessage = errorMessage;
		}
		
		/**
		 *  Contains the provider's name
		 */
		public function get provider():String
		{
			return this._provider;
		}
		public function set provider(provider:String):void
		{
			this._provider = provider;
		}
		
		/**
		 *  Contains the token (oauth 1 & 2)
		 */
		public function get accessToken():String
		{
			return this._accessToken;
		}
		
		/**
		 *  Contains the token (oauth 1 & 2)
		 */
		public function get access_token():String
		{
			return this._accessToken;
		}
		
		/**
		 *  Contains the token (oauth 1 & 2)
		 */
		public function get oauth_token():String
		{
			return this._accessToken;
		}
		
		/**
		 *  Contains the token secret (oauth 1)
		 */
		public function get oauth_token_secret():String
		{
			return this._accessTokenSecret;
		}
		
		/**
		 *  Contains the validity duration of the token(s)
		 */
		public function get expires():Number
		{
			return this._expires;
		}
		
		/**
		 *  Contains the state received by oauth.io
		 */
		public function get state():String
		{
			return this._state;
		}
		
		/**
		 *  Contains the description of the API's requests
		 */
		public function get request():Object
		{
			return this._request;
		}
	
		/**
		 *  Contains the data received by oauth.io
		 */
		public function get data():Object
		{
			return this._data;
		}
		
		/**
		 *  Contains the data used by the http calls
		 */
		public function get requestData():Object
		{
			return this._requestData;
		}
		
		/**
		 *  Parse an oauth.io result and set the properties of this event
		 * 
		 *  @param data The oauthd/oauth.io data to parse
		 */
		public function parseData(data:Object):void
		{
			if (data is String) {
				try {
					data = JSON.parse(data.toString());
				} catch(e:Error) {
					_errorMessage = "Could not parse oauthio result";
					_error = "unknown";
					return;
				}
			}
			
			if ( ! data || ! data.provider)
				return;
			
			if (data.status === "error" || data.status === "fail") {
				_errorMessage = data.message;
				_error = data.status;
				_data = data.data;
				return;
			}
			
			if (data.status !== "success" || ! data.data) {
				_errorMessage = "error in response";
				_error = "response";
				return;
			}
			
			if ( ! data.state) {
				_errorMessage = "missing state in response";
				_error = "response";
				return;
			}

			if (data.data.access_token) this._accessToken = data.data.access_token;
			if (data.data.oauth_token) this._accessToken = data.data.oauth_token;
			if (data.data.oauth_token_secret) this._accessTokenSecret = data.data.oauth_token_secret;
			if (data.data.expires) this._expires = data.data.expires;
			if (data.data.request) {
				this._request = data.data.request;
				this._requestData = {};
				delete data.data.request;
				if (data.data.access_token) this._requestData.token = data.data.access_token;
				if (data.data.oauth_token) this._requestData.oauth_token = data.data.oauth_token;
				if (data.data.oauth_token_secret) this._requestData.oauth_token_secret = data.data.oauth_token_secret;
				if (this._request.required) {
					for (var i:String in this._request.required)
						this._requestData[this._request.required[i]] = data.data[this._request.required[i]];
				}
			}
			this._data = data.data;
		}
		
		/**
		 *  Returns a new io.oauth.OAuthHTTPService bound to this event
		 */
		public function http() : OAuthHTTPService
		{
			 var service:OAuthHTTPService = new OAuthHTTPService();
			 service.from = this;
			 return service;
		}
	}
}