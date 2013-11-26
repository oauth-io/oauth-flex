package io.oauth
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	[Event(name="OAuthError", type="io.oauth.OAuthEvent")]
	[Event(name="OAuthToken", type="io.oauth.OAuthEvent")]

	/**
	 * The io.oauth.OAuthPopup is bound to a popup called by
	 * OAuth.popup(), so you can separate the event listeners depending
	 * on the provider or the context.
	 */
	public class OAuthPopup extends EventDispatcher
	{
		public function OAuthPopup(target:IEventDispatcher=null)
		{
			super(target);
		}
	}
}