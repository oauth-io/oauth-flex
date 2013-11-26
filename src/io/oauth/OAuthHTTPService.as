package io.oauth
{
	import mx.rpc.AsyncResponder;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.mxml.HTTPService;

	/**
	 *  The io.oauth.OAuthHTTPService class wraps the HTTPService class to make
	 *  authorized requests from the informations in a io.oauth.OAuthEvent.
	 */
	public class OAuthHTTPService extends HTTPService
	{
		[Bindable] public var from:OAuthEvent;

		private var _resultFormat:String;

		/**
		 *  The result format "json" specifies that results should be returned as an ActionScript object.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public static const RESULT_FORMAT_JSON:String = "json";

		/**
		 *  Indicates that the data being sent by the HTTP service is encoded as application/json.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public static const CONTENT_TYPE_JSON:String = "application/json";

		/**
		 * Creates a new OAuthHTTPService.
		 * This constructor is usually called by the generated code of an MXML document,
		 * or by OAuthEvent.http()
		 * You can use the io.oauth.OAuthHTTPService class to create an HTTPService using the
		 * io.oauth.OAuthEvent informations to make authorized requests.
		 *
		 * @param rootURL The URL the HTTPService should use when computing relative URLS.
		 *
		 * @param destination An HTTPService destination name in the service-config.xml file.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function OAuthHTTPService(rootURL:String=null, destination:String=null)
		{
			super(rootURL, destination);
		}

		[Inspectable(enumeration="object,array,json,xml,flashvars,text,e4x", defaultValue="object", category="General")]
		/**
		 *  Value that indicates how you want to deserialize the result
		 *  returned by the HTTP call. The value for this is based on the following:
		 *  <ul>
		 *  <li>Whether you are returning XML or name/value pairs.</li>
		 *  <li>How you want to access the results; you can access results as an object,
		 *    text, or XML.</li>
		 *  </ul>
		 *
		 *  <p>The default value is <code>object</code>. The following values are permitted:</p>
		 *  <ul>
		 *  <li><code>object</code> The value returned is XML and is parsed as a tree of ActionScript
		 *    objects. This is the default.</li>
		 *  <li><code>array</code> The value returned is XML and is parsed as a tree of ActionScript
		 *    objects however if the top level object is not an Array, a new Array is created and the result
		 *    set as the first item. If makeObjectsBindable is true then the Array
		 *    will be wrapped in an ArrayCollection.</li>
		 *  <li><code>json</code> The value returned is JSON, which is parsed into an ActionScript object.
		 *  <li><code>xml</code> The value returned is XML and is returned as literal XML in an
		 *    ActionScript XMLnode object.</li>
		 *  <li><code>flashvars</code> The value returned is text containing
		 *    name=value pairs separated by ampersands, which
		 *  is parsed into an ActionScript object.</li>
		 *  <li><code>text</code> The value returned is text, and is left raw.</li>
		 *  <li><code>e4x</code> The value returned is XML and is returned as literal XML
		 *    in an ActionScript XML object, which can be accessed using ECMAScript for
		 *    XML (E4X) expressions.</li>
		 *  </ul>
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		override public function get resultFormat():String
		{
			return _resultFormat;
		}
		override public function set resultFormat(rf:String):void
		{
			_resultFormat = rf;
			if (rf == 'json')
				rf = 'text';
			super.resultFormat = rf;
		}

		[Inspectable(enumeration="application/x-www-form-urlencoded,application/json,application/xml", defaultValue="application/x-www-form-urlencoded", category="General")]
		/**
		 *  Type of content for service requests.
		 *  The default is <code>application/x-www-form-urlencoded</code> which sends requests
		 *  like a normal HTTP POST with name-value pairs. <code>application/xml</code> send
		 *  requests as XML and <code>application/json</code> send requests as JSON.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		override public function get contentType():String
		{
			return super.contentType;
		}
		override public function set contentType(c:String):void
		{
			super.contentType = c;
		}

		/**
		 *  Executes an HTTPService request. The parameters are optional, but if specified should
		 *  be an Object containing name-value pairs or an JSON/XML object depending on the <code>contentType</code>.
		 *
		 *  If the <code>from</code> property is set to a succeeded io.oauth.OAuthEvent, the oauth tokens are
		 *  injected in the request.
		 * 	If the provider's authorization method is OAuth 1, the request will be proxified via https://oauth.io.
		 *
		 *  @param parameters An Object containing name-value pairs or an
		 *  JSON/XML object, depending on the content type for service
		 *  requests.
		 *
		 *  @return An object representing the asynchronous completion token. It is the same object
		 *  available in the <code>result</code> or <code>fault</code> event's <code>token</code> property.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		override public function send(parameters:Object = null):AsyncToken
		{
			if (parameters == null)
				parameters = request;
			if (_resultFormat == 'json') {
				this.headers['Accept'] = "application/json; charset=utf-8";
				if ( ! this.serializationFilter)
					this.serializationFilter = new JSONSerializer();
			}
			if (contentType == 'application/json')
				parameters = JSON.stringify(parameters);

			if (from && from.request && from.access_token) {
				var k:String;
				if (from.oauth_token && from.oauth_token_secret) {
					if (url && url.substr(0,1) !== '/')
						url = '/' + url;
					url = from.oauth.oauthd_url + '/request/' + from.provider + url;
					headers.oauthio = 'k=' + from.oauth.publicKey;
					headers.oauthio += '&oauthv=1';
					for (var i:String in from.requestData)
						headers.oauthio += '&' + encodeURIComponent(i) + "=" + encodeURIComponent(from.requestData[i]);
				}
				else {
					if ( ! url.match(/^[a-z]{2,16}:\/\//)) {
						if (url.substr(0,1) !== '/')
							url = '/' + url;
						url = from.request.url + url;
					}
					url = replaceParam(url, from.requestData, from.request.parameters);

					var qs:Array = [];
					if (from.request.query) {
						for (k in from.request.query) {
							qs.push(encodeURIComponent(k) + "=" + encodeURIComponent(replaceParam(from.request.query[k], from.requestData, from.request.parameters)));
						}
					}
					if (url.indexOf('?') !== -1)
						url += '&' + qs.join('&');
					else
						url += '?' + qs.join('&');

					if (from.request.headers) {
						for (k in from.request.headers) {
							headers[k] = replaceParam(from.request.headers[k], from.requestData, from.request.parameters)
						}
					}
				}
			}

			return super.send(parameters);
		}

		private function replaceParam(param:String, rep:Object, rep2:Object):String
		{
			param = param.replace(/\{\{(.*?)\}\}/g, function(...m):String {
				return rep[m[1]] || "";
			});
			if (rep2)
				param = param.replace(/\{(.*?)\}/g, function(...m):String {
					return rep2[m[1]] || "";
				});
			return param;
		}
	}
}

import mx.rpc.http.AbstractOperation;
import mx.rpc.http.SerializationFilter;

class JSONSerializer extends SerializationFilter
{
	override public function deserializeResult(operation:AbstractOperation, result:Object):Object
	{
		return JSON.parse(result as String);
	}
}