package au.com.clinman.events
{
	import flash.events.Event;
	
	public class UploadCompleteEvent extends Event
	{
		private var _result:XML = new XML();
		
		public function UploadCompleteEvent(type:String, argResult:XML, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._result = argResult;
		}
		
		public function get result():XML
		{
			return this._result;
		}
		
		public static const COMPLETE:String = "UploadCompleteEvent.COMPLETE";
	}
}