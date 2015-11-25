package au.com.clinman.events
{
	import flash.events.Event;

	public class UploadProgressEvent extends Event
	{
		private var _percentComplete:Number = 0;
		
		public function UploadProgressEvent(type:String, percentComplete:Number, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._percentComplete = percentComplete;
		}
		
		public function get percentComplete():Number
		{
			return this._percentComplete;
		}
		
		public static const PROGRESS:String = "UploadProgressEvent.PROGRESS";
	}
}