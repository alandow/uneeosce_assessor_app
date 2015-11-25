////////////////////////////////////////////////////////////////////////////////
//
//  Author ILYA GOLOVACH (aka FlexIncubator)
//  http://flexincubator.com
//  flexincubator@gmail.com
//  2012
//
////////////////////////////////////////////////////////////////////////////////

package au.com.clinman.mobile.lib
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLVariables;
	
	public class CustomUrlSchema
	{
		//----------------------------------------------------------------------
		//
		//  Public properties
		//
		//----------------------------------------------------------------------
		
		//----------------------------------
		//  instance
		//----------------------------------
		private static var _instance:CustomUrlSchema;
		
		public static function get instance():CustomUrlSchema
		{
			if (!_instance)
			{
				_instance = new CustomUrlSchema();
			}
			
			return _instance;
		}
		
		//----------------------------------
		//  paramsString
		//----------------------------------
		private var _paramsString:String;
		
		/**
		 * 
		 */
		public function get paramsString():String
		{
			return _paramsString;
		}
		
		//
		//URL string
		//
		
		private var _configurl:String;
		
		/**
		 * 
		 */
		public function get configurl():String
		{
			return _configurl;
		}
		
		
		//----------------------------------
		//  userId
		//----------------------------------
		private var _userId:String;
		
		/**
		 * 
		 */
		public function get userId():String
		{
			return _userId;
		}
		
		
		
		
		//----------------------------------
		//  token
		//----------------------------------
		private var _token:String;
		
		/**
		 * 
		 */
		public function get token():String
		{
			return _token;
		}
		
		
		//----------------------------------
		//  initialized
		//----------------------------------
		private var _initialized:Boolean = false;
		
		/**
		 * 
		 */
		public function get initialized():Boolean
		{
			return _initialized;
		}
		
		//----------------------------------------------------------------------
		//
		//  Constructor
		//
		//----------------------------------------------------------------------
		
		public function CustomUrlSchema()
		{
		}
		
		//----------------------------------------------------------------------
		//
		//  Public methods
		//
		//----------------------------------------------------------------------
		
		public function parse(keyValuePairs:String):void
		{
			var i:int = keyValuePairs.indexOf("?");
			_paramsString = keyValuePairs.substring(i + 1);
			var urlVars:URLVariables = new URLVariables(_paramsString);
			_userId = urlVars.userid;
			_token = urlVars.token;
			_configurl = urlVars.config;
			_initialized = true;
			//dispatchEvent(new Event(Event.INIT));
		}
		
	}
}