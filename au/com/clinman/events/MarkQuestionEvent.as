package au.com.clinman.events
{
	import flash.events.Event;
	
	public class MarkQuestionEvent extends Event
	{
		
		public function MarkQuestionEvent(type:String, questionID:String, value:String, buttonid:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._questionID = questionID;
			this._value = value;
			this._buttonid = buttonid;
		}
		
		
		private var _value:String = "";
		public function get value():String
		{
			return _value;
		}
		
		private var _buttonid:String = '0';
		public function get buttonid():String
		{
			return _buttonid;
		}	
		
		private var _questionID:String = "";
		
		
		public function get questionID():String
		{
			return this._questionID;
		}
				
		public static const EVENT:String = "MarkQuestionEvent.EVENT";
	}
}
