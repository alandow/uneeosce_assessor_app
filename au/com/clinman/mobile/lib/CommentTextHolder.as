package au.com.clinman.mobile.lib
{
	[Bindable]
	public class CommentTextHolder
	{
		public function CommentTextHolder(text:String="")
		{
			this._text = text;
		}
		
		public var _text:String = "";
		
		public function set text(value:String):void{
			_text = value;
			trace('setting text in CommentTextHolder');
		}
		
		public function get text():String{
			trace('getting text from CommentTextHolder');
			return _text;
		}
	}
}