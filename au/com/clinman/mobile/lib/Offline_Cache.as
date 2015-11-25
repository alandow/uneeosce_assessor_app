package au.com.clinman.mobile.lib
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	//import flash.security.X500DistinguishedName;
	
	public class Offline_Cache extends EventDispatcher
	{
		public function Offline_Cache(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		private var fileIO:FileIO = new FileIO();
		
		private var _records:XML = new XML();
		
		private var _student_list_cache:XML = new XML();
		
		private var _exam_cache:XML = new XML();
		
		
		
		public function set records_cache(value:XML):void{
			fileIO.writeSettingAsXML('records_cache', value)
		}
		
		// return the offline records
		public function get records_cache():XML{
			_records = fileIO.readSettingAsXML('records_cache').data[0];
			return _records;	
		}
		
		// recieve and save offline students for an exam
		public function update_student_list_cache_for_exam(value:XML, examID:String):void{
			fileIO.update_student_list_cache_for_exam(value, examID);
		}
		

		
		// save the offline cache of lookups
		public function set exam_cache(value:XML):void{
			fileIO.updateExamCache(value);
		}
		
		// retrieve
		public function get exam_cache():XML{
			return XML(fileIO.readCache('exam_cache'));
		}
		
		
		public function getRecordsByStudentID(ID:String):XML{
			_records = fileIO.readSettingAsXML('records_cache').data[0];
			return new XML(<data>{_records.record.(studentid==ID)}</data>); 
		}
		
		public function newAssessmentRecord(recordXML:XML):void{
		//	trace('updating using updatedrecordXML which is:'+updatedrecordXML);
	
		}
		
		public function getAllRecords():XML{
			return _records;
		}
	}
}