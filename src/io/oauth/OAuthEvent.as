package io.oauth
{
	import flash.events.Event;
	
	public class OAuthEvent extends Event
	{
		public static const ERROR:String = "OAuthError";
		public static const TOKEN:String = "OAuthToken";
		
		private var _error:String;
		private var _errorMessage:String;
		
		private var _provider:String;
		private var _accessToken:String;
		private var _expires:Number;
		private var _data:Object;
		private var _state:String;

		public function OAuthEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function get error():String
		{
			return this._error;
		}
		
		public function set error(error:String):void
		{
			this._error = error;
		}
		
		public function get errorMessage():String
		{
			return this._errorMessage;
		}
		
		public function set errorMessage(errorMessage:String):void
		{
			this._errorMessage = errorMessage;
		}
		
		public function get provider():String
		{
			return this._provider;
		}
		
		public function set provider(provider:String):void
		{
			this._provider = provider;
		}
		
		public function get accessToken():String
		{
			return this._accessToken;
		}
		
		public function get expires():Number
		{
			return this._expires;
		}
		
		public function get state():String
		{
			return this._state;
		}
	
		public function get data():Object
		{
			return this._data;
		}
		
		public function set data(data:Object):void
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
			if (data.data.expires) this._expires = data.data.expires;
			this._data = data.data;
		}
	}
}