package au.com.clinman.mobile.lib
{
	import flash.system.Capabilities;
	
	import spark.components.TextInput;
	import spark.events.TextOperationEvent;
	
	public class FixedTextInput extends TextInput
	{
		public function FixedTextInput()
		{
			//TODO: implement function
			super();
			this.addEventListener(TextOperationEvent.CHANGE, handleTextOperationEvent)
		}
		
		//override protected function 
		private function handleTextOperationEvent(e:TextOperationEvent):void{
			if(this.text.length == 1 && flash.system.Capabilities.version.substr(0,3).toUpperCase() == "IOS")
				
			{
				
				this.insertText(this.text);  //This does not fire the change event.
				
			}
		}
		
		
	}
}