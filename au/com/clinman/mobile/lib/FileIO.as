package au.com.clinman.mobile.lib
{
	
	
	
	import au.com.clinman.utils.XMLUtils;
	
	import com.adobe.utils.XMLUtil;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	import flash.xml.XMLNodeType;
	
	import mx.utils.Base64Decoder;
	import mx.validators.StringValidator;
	
	
	/**
	 *  
	 * provides some methods for file IO. Saving, opening arbitrary files, diaplying HTML formatted strings for printing, getting a setting
	 * 
	 */
	public class FileIO
	{
		public function FileIO()
		{
			super();
		}
		
		// an encryption key
		private static const KEY:String = 'c06d35fe440e6946';
		
		/**
		 *  @private
		 * 
		 */
		private var _file:File;
		/**
		 *  @private
		 * 
		 */
		private var _fileStream:FileStream;
		/**
		 *  @private
		 * 
		 */
		private var _fileMode:FileMode;
		
		
		/**
		 *  @private
		 * 
		 */
		private var desktopDir:File = File.desktopDirectory;
		
		/**
		 *  @private
		 * 
		 */
		private var fileString:String;
		
		/**
		 *  @private
		 */
		private var fileExt:String;
		
		/**
		 *  @private 
		 */
		private var newFile:File;
		
		/**
		 *  @private
		 * 
		 */
		private var newFile2:File;
		
		/**@private**/
		private var offlineFilePath:String =  'offline.xml';
		
		private var settingsFilePath:String = 'settings.xml';
		/**@private
		 * The initial settings
		 * **/
		private var offlineXML:XML = <data><exam_cache/><answer_cache/></data>;
		
		// some deafult data
		private var settingsXML:XML = <data>
										<functionpath>https://your_UNE_eOSCE_URL.com/backend/service.php</functionpath>
										<systemname>UNE eOSCE</systemname>
										<firstrun>true</firstrun>
									  </data>;
		
		// some demo data
		private var _demoXML:XML = <data>
<exam_cache>
<instance><id>-1</id>
<name>A demo examination- Hand Washing</name>
<description><![CDATA[A demo examination- Hand Washing]]></description>
<scale>
    <item id="4">
      <id>4</id>
      <short_description><![CDATA[S]]></short_description>
      <long_description><![CDATA[Performed Item Satisfactorily]]></long_description>
      <needs_comment/>
      <value>1</value>
    </item>
    <item id="5">
      <id>5</id>
      <short_description><![CDATA[NS]]></short_description>
      <long_description><![CDATA[Did not Perform Item Satisfactorily]]></long_description>
      <needs_comment>true</needs_comment>
      <value>0</value>
    </item>
  </scale>
<questiondata>
<question id='1'><id>1</id><text><![CDATA[Thoroughly wets hands with warm water]]></text><type>0</type></question>
<question id='2'><id>2</id><text><![CDATA[Applies liquid soap or disinfectant from dispenser (essential!)]]></text><type>1</type></question>
<question id='4'><id>4</id><text><![CDATA[right palm over left dorsum and vice versa]]></text><type>0</type></question>
<question id='5'><id>5</id><text><![CDATA[palm to palm with fingers interlaced]]></text><type>0</type></question>
<question id='6'><id>6</id><text><![CDATA[back of fingers to opposing palms with fingers interlocked]]></text><type>0</type></question>
<question id='7'><id>7</id><text><![CDATA[palm to palm with fingers interlaced]]></text><type>0</type></question>
<question id='8'><id>8</id><text><![CDATA[right thumb clasped in left palm and vice versa]]></text><type>0</type></question>
<question id='9'><id>9</id><text><![CDATA[fingers of right hand clasped in left palm and vice versa]]></text><type>0</type></question>
<question id='10'><id>10</id><text><![CDATA[Rinses hands thoroughly and appropriately (essential!)]]></text><type>1</type></question>
<question id='11'><id>11</id><text><![CDATA[Turns taps off with elbows]]></text><type>0</type></question>
<question id='12'><id>12</id><text><![CDATA[Dries hands with paper towel]]></text><type>0</type></question>
<question id='13'><id>13</id><text><![CDATA[Rinses hands thoroughly and appropriately]]></text><type>0</type></question>
</questiondata>
<students>
<data>
<student><id>0</id><searchfield><![CDATA[SAM STUDENT 123456]]></searchfield><fname><![CDATA[SAM]]></fname><lname><![CDATA[STUDENT]]></lname><studentnum>123456</studentnum><hasimage>0</hasimage><thumb>thumb4.jpg</thumb><image>demoimage4.jpg</image></student>
<student><id>1</id><searchfield><![CDATA[SARAH STUDENT 123457]]></searchfield><fname><![CDATA[SARAH]]></fname><lname><![CDATA[STUDENT]]></lname><studentnum>123457</studentnum><hasimage>0</hasimage><thumb>thumb2.jpg</thumb><image>demoimage2.jpg</image></student>
<student><id>3</id><searchfield><![CDATA[JACK SMITH 123458]]></searchfield><fname><![CDATA[JACK]]></fname><lname><![CDATA[SMITH]]></lname><studentnum>123458</studentnum><hasimage>0</hasimage><thumb>thumb3.jpg</thumb><image>demoimage3.jpg</image></student>
<student><id>4</id><searchfield><![CDATA[NYMPHADORA TONKS 654321]]></searchfield><fname><![CDATA[Nymphadora]]></fname><lname><![CDATA[Tonks]]></lname><studentnum>654321</studentnum><hasimage>0</hasimage><thumb>thumb1.jpg</thumb><image>demoimage1.jpg</image></student>
</data>
</students>
</instance>
</exam_cache></data>;
		
		
		
		public function get demoXML():XML
		{
			return _demoXML;
		}
		
		public function set demoXML(value:XML):void
		{
			_demoXML = value;
		}
		
		public function openFile(path:String):String{
			//	trace('Storage/openFile is opening file:'+path)
			var file:File = File.applicationDirectory.resolvePath(path);
			if (file.exists){
				var stream:FileStream = new FileStream()
				stream.open(file, FileMode.READ);
				return stream.readUTFBytes(stream.bytesAvailable);
				stream.close()
			}else{
				// make a new file
				return '';
			}
		}
		
		public static function htmlUnescape(str:String):String {
			return new XMLDocument(str).firstChild.nodeValue;
		}
		
		public static function htmlEscape(str:String):String {
			return XML( new XMLNode( XMLNodeType.TEXT_NODE, str ) ).toXMLString();
		}
		
		
		/**
		 *  loadSetting loads a setting from a settings XML found typically at {applicationDirectory}/resources/data/settings.xml.
		 * Returns a string which can be used to define a setting, if setting is not there returns a blank string.
		 * 
		 * @param whichSetting the setting to return
		 * */ 
		public function readSetting(whichSetting:String):String{
			//	trace('Storage.loadSettings called');
			// load file, parse XML
			var settingsFile:File;
			settingsFile = File.applicationStorageDirectory.resolvePath(settingsFilePath);
			var stream:FileStream = new FileStream;
			var returnval:String = '';
			if (settingsFile.exists) 
			{
				stream.open(settingsFile, FileMode.READ);	    			
				settingsXML = XML(stream.readUTFBytes(stream.bytesAvailable));
				stream.close();
				try {
					returnval = settingsXML.child(whichSetting)[0].toString();	
				} catch( error:Error ) {
					return '';
				}
				//	trace(value)
				return returnval;
			}else{
				// make a new file
				//newFile2 = new File(settingsFile);
				stream.open(settingsFile, FileMode.WRITE);
				stream.writeUTFBytes(settingsXML);
				stream.close();
				returnval = settingsXML.child(whichSetting)[0].toString();	
				return returnval;
			}			
		}
		
		
		/**
		 *  loadSetting loads a setting from a cache XML found typically at {applicationDirectory}/resources/data/offline.xml.
		 * Returns a string, if data is not there returns a blank string.
		 * 
		 * @param whichSetting the setting to return
		 * */ 
		public function readCache(which:String):String{
			//	trace('Storage.loadSettings called');
			// load file, parse XML
			var file:File;
			file = File.applicationStorageDirectory.resolvePath(offlineFilePath);
			var stream:FileStream = new FileStream;
			var returnval:String = '<data/>';
			if (file.exists) 
			{
				stream.open(file, FileMode.READ);	    			
				offlineXML = XML(stream.readUTFBytes(stream.bytesAvailable));
				stream.close();
				try {
					returnval = offlineXML.child(which)[0].toString();	
				} catch( error:Error ) {
					return '<data/>';
				}
				//	trace(value)
				return returnval;
			}else{
				// make a new file
				//newFile2 = new File(settingsFile);
				
				stream.open(file, FileMode.WRITE);
				stream.writeUTFBytes(offlineXML);
				stream.close();
				returnval = offlineXML.child(which)[0].toString();	
				return returnval;
			}			
		}
		
		
		// write a setting
		public function writeSetting(whichsetting:String, value:String):Boolean{
			// load file, parse XML
			try{
				trace('Setting '+whichsetting+' to '+value);
				var settingsFile:File;
				settingsFile = File.applicationStorageDirectory.resolvePath(settingsFilePath);
				if(settingsXML.hasOwnProperty(whichsetting)){
					trace('setting exists');
					settingsXML.replace(whichsetting, <{whichsetting}>{value}</{whichsetting}>);
				}else{
					settingsXML.appendChild(<{whichsetting}>{value}</{whichsetting}>);
				}
				//settingsXML.whichsetting = value;
				//newFile2 = new File(settingsFile);
				trace('settingsXML is now:'+settingsXML);
				var stream:FileStream = new FileStream;
				stream.open(settingsFile, FileMode.WRITE);
				stream.writeUTFBytes(settingsXML);
				stream.close();
				return true
			}catch(e:Error){return false}
			return false;
		}
		
		public function readSettingAsXML(whichSetting:String):XML{
			//	trace('Storage.loadSettings called');
			// load file, parse XML
			var settingsFile:File;
			settingsFile = File.applicationStorageDirectory.resolvePath(settingsFilePath);
			var stream:FileStream = new FileStream;
			var returnval:XML = new XML;
			if (settingsFile.exists) 
			{
				stream.open(settingsFile, FileMode.READ);	    			
				offlineXML = XML(stream.readUTFBytes(stream.bytesAvailable));
				stream.close();
				try {
					returnval = offlineXML.child(whichSetting)[0];	
				} catch( error:Error ) {
					return new XML();
				}
				//	trace(value)
				return returnval;
			}else{
				// make a new file
				//newFile2 = new File(settingsFile);
				stream.open(settingsFile, FileMode.WRITE);
				stream.writeUTFBytes(offlineXML);
				stream.close();
				returnval = offlineXML.child(whichSetting)[0].toString();	
				return returnval;
			}			
		}
		
		public function get cache_exists():Boolean{
			var settingsFile:File;
			settingsFile = File.applicationStorageDirectory.resolvePath(offlineFilePath);
			return settingsFile.exists;
		}
		
		
		public function writeSettingAsXML(whichsetting:String, value:XML):Boolean{
			// load file, parse XML
			try{
				//trace('Setting '+whichsetting+' to '+value);
				var settingsFile:File;
				settingsFile = File.applicationStorageDirectory.resolvePath(settingsFilePath);
				if(offlineXML.hasOwnProperty(whichsetting)){
					trace('setting XML exists');
					offlineXML.replace(whichsetting, <{whichsetting}>{value}</{whichsetting}>);
				}else{
					offlineXML.appendChild(<{whichsetting}>{value}</{whichsetting}>);
				}
				//settingsXML.whichsetting = value;
				//newFile2 = new File(settingsFile);
				var stream:FileStream = new FileStream;
				stream.open(settingsFile, FileMode.WRITE);
				stream.writeUTFBytes(offlineXML);
				stream.close();
				return true
			}catch(e:Error){return false}
			return false;
		}
		
		
		public function writeCacheAsXML(whichsetting:String, value:XML):Boolean{
			// load file, parse XML
			try{
				//trace('Setting '+whichsetting+' to '+value);
				var file:File;
				file = File.applicationStorageDirectory.resolvePath(offlineFilePath);
				if(offlineXML.hasOwnProperty(whichsetting)){
					offlineXML.replace(whichsetting, <{whichsetting}>{value}</{whichsetting}>);
				}else{
					offlineXML.appendChild(<{whichsetting}>{value}</{whichsetting}>);
				}
				//settingsXML.whichsetting = value;
				//newFile2 = new File(settingsFile);
				var stream:FileStream = new FileStream;
				stream.open(file, FileMode.WRITE);
				stream.writeUTFBytes(offlineXML);
				stream.close();
				return true
			}catch(e:Error){return false}
			return false;
		}
		
		/**
		 * Cache an exam
		 * */
		
		public function updateExamCache(examDefinition:XML):Boolean{
			try{
				var stream:FileStream = new FileStream;
				var cacheFile:File;
				cacheFile = File.applicationStorageDirectory.resolvePath(offlineFilePath);
				if (!cacheFile.exists) 
				{
					stream.open(cacheFile, FileMode.WRITE);
					stream.writeUTFBytes(offlineXML);
					stream.close();
				}
				// read existinc cache
				stream.open(cacheFile, FileMode.READ);	    	
				offlineXML = XML(stream.readUTFBytes(stream.bytesAvailable));
				stream.close();
				// check that this hasn't already been started
				//if(
				offlineXML.replace('exam_cache', examDefinition);
				stream.open(cacheFile, FileMode.WRITE);
				stream.writeUTFBytes(offlineXML);
				stream.close();
				return true
				
			}catch(e:Error){return false}
			return false;
		}
		
		public function startAnswerCache(answersForExamDefinition:String, studentID:String, examID:String):Boolean{
			try{
				var cacheFile:File;
				cacheFile = File.applicationStorageDirectory.resolvePath(offlineFilePath);
				var stream:FileStream = new FileStream;
				// read existinc cache
				stream.open(cacheFile, FileMode.READ);	    	
				offlineXML = XML(stream.readUTFBytes(stream.bytesAvailable));
				stream.close();
				// check that this hasn't already been started
				
				if(offlineXML.answer_cache.exam.((examid==examID)&&(studentid==studentID)).length()<1){
					trace('Making new cache for student '+studentID);
					offlineXML.answer_cache.appendChild(new XML(answersForExamDefinition));
					//trace('cachefile is now:'+offlineXML);
					stream.open(cacheFile, FileMode.WRITE);
					stream.writeUTFBytes(offlineXML);
					stream.close();
				}else{
					trace('re-using cache for student'+studentID)
				}
				return true
			}catch(e:Error){trace(e.message);return false}
			return false;
		}
		
		
		public function updateAnswerCache(answersForExam:String, studentID:String, examID:String):Boolean{
			//trace('updateAnswerCache is about to write:'+answersForExam);
			
			try{
				var cacheFile:File;
				cacheFile = File.applicationStorageDirectory.resolvePath(offlineFilePath);
				var stream:FileStream = new FileStream;
				// read existinc cache
				stream.open(cacheFile, FileMode.READ);	    	
				offlineXML = XML(stream.readUTFBytes(stream.bytesAvailable));
				stream.close();				
				offlineXML.answer_cache.exam.((examid==examID)&&(studentid==studentID)).replace('questiondata', new XML(answersForExam));
				stream.open(cacheFile, FileMode.WRITE);
				stream.writeUTFBytes(offlineXML);
				stream.close();
				
				return true
			}catch(e:Error){trace(e.message);return false}
			return false;
		}
		
		public function removeAnswerCache(studentID:String, examID:String, includecompleted:Boolean = false):Boolean{
			// check to see if the cache for this exam instance is there, If not, we probably deleted it earlier 
			if(offlineXML.answer_cache.exam.((examid==examID)&&(studentid==studentID)&&(includecompleted?true:(completed != 'true'))).length()>0){
				try{
					trace('Deleting cache for student:'+studentID+' and examID:'+examID);
					var cacheFile:File;
					cacheFile = File.applicationStorageDirectory.resolvePath(offlineFilePath);
					var stream:FileStream = new FileStream;
					// read existinc cache
					stream.open(cacheFile, FileMode.READ);	    	
					offlineXML = XML(stream.readUTFBytes(stream.bytesAvailable));
					stream.close();				
					deleteNode(offlineXML.answer_cache.exam.((examid==examID)&&(studentid==studentID)&&(includecompleted?true:(completed != 'true')))[0]);
					//trace('cachefile is now:'+offlineXML);
					stream.open(cacheFile, FileMode.WRITE);
					stream.writeUTFBytes(offlineXML);
					stream.close();
					return true
				}catch(e:Error){trace('removeAnswerCache says:'+e.message);return false}
				
			}else{
				return true;
			}
			return false;
		}
		
		private var xmlutils:XMLUtils = new XMLUtils();
		public function setAnswerCacheAsCompletedButNotSubmitted(studentID:String, examID:String, userID:String, siteid:String, signatureImageString:String, overallRating:String, additionalRating:String, finalComments:String):Boolean{
			try{
				trace('setting complete for student:'+studentID+' and examID:'+examID);
				var cacheFile:File;
				cacheFile = File.applicationStorageDirectory.resolvePath(offlineFilePath);
				var stream:FileStream = new FileStream;
				// read existinc cache
				stream.open(cacheFile, FileMode.READ);	    	
				offlineXML = XML(stream.readUTFBytes(stream.bytesAvailable));
				stream.close();				
				offlineXML.answer_cache.exam.((examid==examID)&&(studentid==studentID)).completed = 'true'
				offlineXML.answer_cache.exam.((examid==examID)&&(studentid==studentID)).userid = userID;
				offlineXML.answer_cache.exam.((examid==examID)&&(studentid==studentID)).siteid = siteid;
				offlineXML.answer_cache.exam.((examid==examID)&&(studentid==studentID)).signature = signatureImageString;
				offlineXML.answer_cache.exam.((examid==examID)&&(studentid==studentID)).overall_rating = overallRating;
				offlineXML.answer_cache.exam.((examid==examID)&&(studentid==studentID)).additional_rating = additionalRating;
				offlineXML.answer_cache.exam.((examid==examID)&&(studentid==studentID)).overall_comments =  finalComments;
				stream.open(cacheFile, FileMode.WRITE);
				stream.writeUTFBytes(offlineXML);
				stream.close();
				return true
			}catch(e:Error){trace('setAnswerCacheAsCompletedButNotSubmitted says:'+e.message);return false}
			return false;
		}
		
		private function deleteNode( node : XML ) : void {
			delete node.parent().children()[ node.childIndex() ];
		}
		
		public function checkForCurrentUnfinishedExam(examID:String):XML{
			try{
				var cacheFile:File;
				cacheFile = File.applicationStorageDirectory.resolvePath(offlineFilePath);
				var stream:FileStream = new FileStream;
				// read existinc cache
				stream.open(cacheFile, FileMode.READ);	    	
				offlineXML = XML(stream.readUTFBytes(stream.bytesAvailable));
				stream.close();
				// check that this hasn't already been started
				
				if(offlineXML.answer_cache.exam.((examid==examID)&&(completed!='true')).length()>0){
					trace('existing cache is'+offlineXML.answer_cache.exam.((examid==examID)&&(completed!='true'))[0]);
					return offlineXML.answer_cache.exam.((examid==examID)&&(completed!='true'))[0];
				}else{
					return new XML();
				}
			}catch(e:Error){trace('checkForCurrentUnfinishedExam says:'+e.message);return  new XML();}
			return new XML();;
		}
		
		
		public function getUnfinishedExams():XMLList{
			try{
				var cacheFile:File;
				cacheFile = File.applicationStorageDirectory.resolvePath(offlineFilePath);
				var stream:FileStream = new FileStream;
				// read existinc cache
				stream.open(cacheFile, FileMode.READ);	    	
				offlineXML = XML(stream.readUTFBytes(stream.bytesAvailable));
				stream.close();
				// check that this hasn't already been started
				
				if(offlineXML.answer_cache.exam.(completed=='true').length()>0){
					//trace('Unfinished exams cache is'+offlineXML.answer_cache.exam.(completed=='true'));
					return offlineXML.answer_cache.exam.(completed=='true');
				}else{
					return new XMLList();
				}
			}catch(e:Error){trace('getUnfinishedExams says:'+e.message);return  new XMLList();}
			return new XMLList();;
		}
		
		
		public function update_student_list_cache_for_exam(value:XML, examID:String):Boolean{
			try{
				
				var file:File;
				file = File.applicationStorageDirectory.resolvePath(offlineFilePath);
				offlineXML.exam_cache.data.instance.(id=examID).replace('students', <students>{value}</students>);
				//settingsXML.whichsetting = value;
				//newFile2 = new File(settingsFile);
				trace('writing as students:'+value);
				var stream:FileStream = new FileStream;
				stream.open(file, FileMode.WRITE);
				stream.writeUTFBytes(offlineXML);
				stream.close();
				return true
			}catch(e:Error){
				return false}
			return false;
		}
		
		// Gets a student data from the cached data
		public function get_student_from_cache(studentID:String, examID:String):XML{
			var cacheFile:File;
			cacheFile = File.applicationStorageDirectory.resolvePath(offlineFilePath);
			var stream:FileStream = new FileStream;
			// read existing cache
			stream.open(cacheFile, FileMode.READ);	    	
			offlineXML = XML(stream.readUTFBytes(stream.bytesAvailable));
			stream.close();
			// check that this hasn't already been started
			var currentExam:XML = offlineXML.exam_cache.instance.(id==examID)[0];
			
			try{
				if(currentExam.students.data.student.(id==studentID).length()>0){
					trace('got a student match!')
					return currentExam.students.data.student.(id==studentID)[0];
				}else{
					return new XML();
				}
			}catch(e:Error){
				return new XML();
			}
			return new XML();
		}
		
		
		public function clearCache():void{
			var settingsFile:File;
			settingsFile = File.applicationStorageDirectory.resolvePath(offlineFilePath);
			var stream:FileStream = new FileStream;
			stream.open(settingsFile, FileMode.WRITE);
			offlineXML = <data/>;
			stream.writeUTFBytes(offlineXML);
			stream.close();
		}
		
	}
}