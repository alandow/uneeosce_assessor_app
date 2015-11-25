package au.com.clinman.events
{
	import flash.events.Event;
	
	public class StartCommentEvent extends Event
	{
		
		public function StartCommentEvent(type:String, questionID:String, value:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._questionID = questionID;
			this._value = value;
		}
		
		
		private var _value:String = "";
		public function get value():String
		{
			return _value;
		}
				
		private var _questionID:String = "";
		
		
		public function get questionID():String
		{
			return this._questionID;
		}
				
		public static const EVENT:String = "StartCommentEvent.EVENT";
	}
}
