package au.com.clinman.utils
{
	public class XMLUtils
	{
		public function XMLUtils()
		{
		}
		
		public function cdata(data:String):String {
			return "<![CDATA[" + data + "]]>";
		}
	}
}