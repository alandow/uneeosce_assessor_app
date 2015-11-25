package au.com.clinman.mobile.lib
{
	import com.adobe.protocols.dict.events.ErrorEvent;
	import com.hurlant.util.Base64;
	import com.pialabs.eskimo.controls.SkinnableAlert;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	import flash.xml.XMLNodeType;
	
	import mx.messaging.messages.AbstractMessage;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.utils.Base64Encoder;
	import mx.utils.ObjectUtil;
	
	import air.net.URLMonitor;
	
	import au.com.clinman.events.GetExamsForUserCompleteEvent;
	import au.com.clinman.events.GetMarkingSheetDefinitionCompleteEvent;
	import au.com.clinman.events.GetStudentsBySearchStrForFormCompleteEvent;
	import au.com.clinman.events.LogonCompleteEvent;
	import au.com.clinman.events.UploadCompleteEvent;
	import au.com.clinman.events.UploadProgressEvent;
	import au.com.clinman.events.eOSCEErrorEvent;
	import au.com.clinman.utils.XMLUtils;
	
	import org.asclub.net.UploadPostHelper;
	
	public class Web_Service_Interface extends EventDispatcher
	{
		
		
		// a file system interface
		[Bindable]
		private var _io:FileIO = new FileIO();
		
		// getter and setter for fileIO
		
		public static function htmlUnescape(str:String):String {
			return new XMLDocument(str).firstChild.nodeValue;
		}
		
		public static function htmlEscape(str:String):String {
			return XML( new XMLNode( XMLNodeType.TEXT_NODE, str ) ).toXMLString();
		}
		
		
		public function get io():au.com.clinman.mobile.lib.FileIO
		{
			return _io;
		}
		
		public function set io(value:au.com.clinman.mobile.lib.FileIO):void
		{
			_io = value;
		}
		
		// an offline cache to essentially shadow this class. It will be a fallback position for when the service is offine
		[Bindable]
		private var _offline_cache:Offline_Cache= new Offline_Cache();
		
		/**
		 * Returns the offline cache
		 */
		public function get offline_cache():Offline_Cache{
			return _offline_cache;
		}
		
		// the base path for the php files..
		private var _functionPath:String = "";
		
		// accesssor 
		public function set functionPath(value:String):void{
			_functionPath = value;
		}
		
		// a handy iterator
		private var i:int = 0;
		
		// the currently loaded exam ID
		private var _currentFormID:String = "0";
		
		// the currently loaded student ID
		private var _currentStudentID:String = "";
		
		// are we logged in? We're using this to determine whether or not to send cached assessments
		private var _loggedIn:Boolean = false;
		
		// accessors
		public function get loggedIn():Boolean
		{
			return _loggedIn;
		}
		
		public function set loggedIn(value:Boolean):void
		{
			_loggedIn = value;
			// Take the opportunity to check for outstanding exams, submit them
			if(monitor.available&&_loggedIn){
				submitOutstandingAssessments();
			}
		}
		
		// the HTTPservice we'll use to do all our operations
		private var _interfaceService:HTTPService = new HTTPService();
		
		// A monitor object to check for network connectivity. It changes and sends an event when there's a network status change 
		[Bindable]
		private var _monitor:URLMonitor;
		private var _monitorReq:URLRequest = new URLRequest(_io.readSetting('functionpath')+"?app=true")
		
		
		/**
		 * a monitor to check if we're online or not
		 */ 
		public function get monitor():URLMonitor{
			return _monitor;
		}
		
		
		/**
		 * instantiate the whole silly thing
		 * @param target
		 * 
		 */		
		public function Web_Service_Interface(target:IEventDispatcher=null)
		{
			super(target);
			// set the monitor method. HEAD is pretty lightweight
			_monitorReq.method = URLRequestMethod.HEAD;
			_monitor = new URLMonitor(_monitorReq);
			// set a listener for the statis change
			_monitor.addEventListener(StatusEvent.STATUS, monitorStatusHandler);
			// kick it all off
			_monitor.start();
		}
		
		/**
		 * reset the online monitor
		 */ 
		public function resetMonitor():void{
			_monitorReq = new URLRequest(_io.readSetting('functionpath')+"?app=true");
			_monitorReq.method = URLRequestMethod.HEAD;
			_monitor = null;
			_monitor = new URLMonitor(_monitorReq)
			_monitor.stop();
			_monitor.start();
		}
		
		
		/**
		 * let the world know that there's been a status change
		 * @param e
		 * 
		 */		
		protected function monitorStatusHandler(e:StatusEvent):void 
		{
			dispatchEvent(new Event("MONITOR_STATUS_CHANGE", true));
			// sync offline exams here, if we're going back online and logged in
			if(monitor.available&&_loggedIn){
				submitOutstandingAssessments();
			}
		//	SkinnableAlert.show('Monitor Status Change! Is network available?'+monitor.available.toString());
		}
		
		
		/**
		 * logon function
		 * @param username
		 * @param password
		 * 
		 */		
		public function logon(username:String, password:String):void{
			_interfaceService.requestTimeout = 15;
			_interfaceService.request = new Object();
			_interfaceService.url = _io.readSetting('functionpath');
			_interfaceService.request.action = 'login';
			_interfaceService.request.user = username;
			_interfaceService.request.password = password;
			_interfaceService.request.app = 'true';
			_interfaceService.resultFormat = 'text';
			_interfaceService.method = 'POST';
			_interfaceService.addEventListener( ResultEvent.RESULT, logonResultHandler );
			_interfaceService.addEventListener( FaultEvent.FAULT, handleFault );
			// execute the service
			_interfaceService.send();
		}
		
		
		/**
		 * handle the login result
		 * @param e
		 * 
		 */		
		private function logonResultHandler(e:ResultEvent):void{
			_interfaceService.removeEventListener( ResultEvent.RESULT, logonResultHandler );
			_interfaceService.removeEventListener( FaultEvent.FAULT, handleFault );
			var resultXML:XML = new XML('<data/>');
			try{
				resultXML= XML(e.result.toString());
			}catch(e:Error){
				resultXML= XML('<data><error>unexpected result from server</error></data>');
			}
			
			dispatchEvent(new LogonCompleteEvent(LogonCompleteEvent.COMPLETE, resultXML, true, true));
		}
		
		/**
		 * check a token. This token is saved locally, and if it's valid we don't need to log in again
		 * @param token
		 * 
		 */		
		public function checkToken(token:String):void{
			//trace('sending:'+token);
			_interfaceService.requestTimeout = 15;
			_interfaceService.request = new Object();
			_interfaceService.url = _io.readSetting('functionpath');
			_interfaceService.request.action = 'getdetailsbytoken';
			_interfaceService.request.app = 'true';
			_interfaceService.request.token = token;
			_interfaceService.method = 'POST';
			_interfaceService.resultFormat = 'text';
			_interfaceService.addEventListener( ResultEvent.RESULT, checkTokenResultHandler );
			_interfaceService.addEventListener( FaultEvent.FAULT, handleFault );
			// execute the service
			_interfaceService.send();
		}
		
		
		/**
		 *  handle the check token result
		 * @param e
		 * 
		 */		
		private function checkTokenResultHandler(e:ResultEvent):void{
			//trace('checkTokenResultHandler says:'+e.result.toString());
			_interfaceService.removeEventListener( ResultEvent.RESULT, checkTokenResultHandler );
			_interfaceService.removeEventListener( FaultEvent.FAULT, handleFault );
			var resultXML:XML = new XML('<data/>');
			try{
				resultXML= XML(e.result.toString());
			}catch(e:Error){
				resultXML= XML('<data><error>unexpected result from server</error></data>');
			}
			
			dispatchEvent(new LogonCompleteEvent(LogonCompleteEvent.COMPLETE, resultXML, true, true));
		}
		
		//////////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		//Data operations
		//
		///////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		/**
		 * Get a list of examinations for the logged on user.
		 * @param userID
		 * @param token
		 * 
		 */		
		
		public function getExamsForUser(userID:String = "", token:String=""):void{		
			//	dispatchEvent(new WaitEvent(WaitEvent.EVENT, 'searching records', true, true));
			if(_monitor.available){
				trace('Getting data from online');
				_interfaceService.requestTimeout = 15;
				_interfaceService.request = new Object();
				_interfaceService.url = _io.readSetting('functionpath');
				_interfaceService.request.action = 'listexaminstancesforassessorforapp';
				_interfaceService.request.app = 'true';
				_interfaceService.request.userid = userID;
				_interfaceService.request.token = token;
				_interfaceService.resultFormat = 'text';
				_interfaceService.method = 'POST';
				_interfaceService.addEventListener( ResultEvent.RESULT, getExamsForUserResultHandler );
				_interfaceService.addEventListener( FaultEvent.FAULT, handleFault );
				// execute the service
				_interfaceService.send();
			}else{
				// use offline cache
				trace('using offline cache');
				dispatchEvent(new GetExamsForUserCompleteEvent(GetExamsForUserCompleteEvent.DATA_READY, _offline_cache.exam_cache, true, true));
				
			}
			
		}
		
		
		/**
		 * handle the result
		 * @param e
		 * 
		 */		
		private function getExamsForUserResultHandler(e:ResultEvent):void{
			trace("getExamsForUserResultHandler says "+e.result.toString());
			_interfaceService.removeEventListener( ResultEvent.RESULT, getExamsForUserResultHandler );
			_interfaceService.removeEventListener( FaultEvent.FAULT, handleFault );
			try{
				
				var resultXML:XML = new XML(e.result.toString());
				if(resultXML.hasOwnProperty('error')){
					var message:AbstractMessage = new AbstractMessage();
					message.body = resultXML.error.toString();
					dispatchEvent(new FaultEvent(FaultEvent.FAULT, true, true, null, null, message));
				}else{
					// cache exam data
					_offline_cache.exam_cache = new XML('<exam_cache>'+resultXML.instance.toString()+'</exam_cache>');
					dispatchEvent(new GetExamsForUserCompleteEvent(GetExamsForUserCompleteEvent.DATA_READY,resultXML , true, true));
				}
			}catch(err:Error){
				dispatchEvent(new FaultEvent(FaultEvent.FAULT, true, true, null, null, err.message));
			}
			
		}
		
		
		/**
		 * we don't need to get this again- the exams are cached when a user logs on.
		 * @param examid
		 * @param token
		 * 
		 */		
		public function getMarkingSheetDefinition(examid:String = "", token:String=""):void{		
			trace('Getting exam definition for exam ID:'+examid)
			trace('exam definition is:'+_offline_cache.exam_cache.instance.(id==examid))
			// are we online?
			/*if(_monitor.available){
			_interfaceService.requestTimeout = 15;
			_interfaceService.request = new Object();
			_interfaceService.url = _io.readSetting('functionpath');
			_interfaceService.request.action = 'getmarkingsheetdefinition';
			_interfaceService.request.id = id;
			_interfaceService.request.app = 'true';
			_interfaceService.request.token = token;
			_interfaceService.resultFormat = 'text';
			_interfaceService.method = 'POST';
			_interfaceService.addEventListener( ResultEvent.RESULT, getMarkingSheetDefinitionResultHandler );
			_interfaceService.addEventListener( FaultEvent.FAULT, handleFault );
			// execute the service
			_interfaceService.send();
			}else{
			// if not, see if there's a cache
			
			}*/
			//trace( _offline_cache.exam_cache);
			dispatchEvent(new GetMarkingSheetDefinitionCompleteEvent(GetMarkingSheetDefinitionCompleteEvent.DATA_READY, _offline_cache.exam_cache.instance.(id==examid)[0], true, true));
		}
		
		/*		private function getMarkingSheetDefinitionResultHandler(e:ResultEvent):void{
		//	trace("getMarkingSheetDefinitionResultHandler says "+e.result.toString());
		_interfaceService.removeEventListener( ResultEvent.RESULT, getMarkingSheetDefinitionResultHandler );
		_interfaceService.removeEventListener( FaultEvent.FAULT, handleFault );
		try{
		var resultXML:XML = new XML(e.result.toString());
		dispatchEvent(new GetMarkingSheetDefinitionCompleteEvent(GetMarkingSheetDefinitionCompleteEvent.DATA_READY, resultXML, true, true));
		}catch(e:Error){
		dispatchEvent(new FaultEvent(FaultEvent.FAULT, true, true, null, null, e.message));
		}
		
		}*/
		
		
		/**
		 * look up a student for an exam. Used for finding a specific kiddie in the list
		 * @param formid
		 * @param token
		 * 
		 */		
		public function getStudentsBySearchStrForForm(formid:String, token:String):void{
			
			_currentFormID = formid;
			trace('cached students for this exam are:'+_offline_cache.exam_cache.instance.(id==formid)[0].students.data[0])
			if(_monitor.available){
				trace('getting from web');
				_interfaceService.requestTimeout = 15;
				_interfaceService.request = new Object();
				_interfaceService.url = _io.readSetting('functionpath');
				_interfaceService.request.app = 'true';
				_interfaceService.request.action = 'liststudentsbysearchstrforform';
				_interfaceService.request.searchstr = "";
				_interfaceService.request.formid = formid;
				_interfaceService.request.token = token;
				_interfaceService.resultFormat = 'text';
				_interfaceService.method = 'POST';
				_interfaceService.addEventListener( ResultEvent.RESULT, getStudentsBySearchStrForFormResultHandler );
				_interfaceService.addEventListener( FaultEvent.FAULT, handleFault );
				// execute the service
				_interfaceService.send();
			}else{
				trace('getting from cache');
				dispatchEvent(new GetStudentsBySearchStrForFormCompleteEvent(GetStudentsBySearchStrForFormCompleteEvent.DATA_READY, _offline_cache.exam_cache.instance.(id==formid)[0].students.data[0], true, true));
			}
		}
		
		
		/**
		 * manage the result
		 * @param e
		 * 
		 */		
		private function getStudentsBySearchStrForFormResultHandler(e:ResultEvent):void{
			//	trace("getMarkingSheetDefinitionResultHandler says "+e.result.toString());
			_interfaceService.removeEventListener( ResultEvent.RESULT, getStudentsBySearchStrForFormResultHandler );
			_interfaceService.removeEventListener( FaultEvent.FAULT, handleFault );
			var resultXML:XML = new XML(e.result.toString());
			// take the opportunity to update the cached student list
			_offline_cache.update_student_list_cache_for_exam(resultXML, _currentFormID);
			dispatchEvent(new GetStudentsBySearchStrForFormCompleteEvent(GetStudentsBySearchStrForFormCompleteEvent.DATA_READY, resultXML, true, true));
		}
		
		
		/**
		 * Submits an assessment
		 * @param studentID
		 * @param formid
		 * @param userid
		 * @param overall_rating
		 * @param additional_rating
		 * @param assessmentdataXML
		 * @param comments
		 * @param signatureImage
		 * @param token
		 * @param suppressEvent Uses a different result handler that doesn't dispatch the event that tells the world that this happened. Used for background operation 
		 * 
		 */		
		public function submitAssessment(studentID:String, formid:String, userid:String, siteid:String, overall_rating:String, additional_rating:String, assessmentdataXML:String, comments:String, signatureImageData:String, practicing:String, token:String, suppressEvent:Boolean = false):void{
			// encode signature as string
			
			
			if(_monitor.available){
				_interfaceService.requestTimeout = 15;
				_interfaceService.request = new Object();
				_interfaceService.url = _io.readSetting('functionpath');
				_interfaceService.request.app = 'true';
				_interfaceService.request.action = 'submitwholeassessment';
				_interfaceService.request.studentid = studentID;
				_interfaceService.request.formid = formid;
				_interfaceService.request.siteid = siteid;
				_interfaceService.request.overall_rating = overall_rating;
				_interfaceService.request.additional_rating = additional_rating;
				_interfaceService.request.assessmentXML = assessmentdataXML;
				_interfaceService.request.comments = comments;
				_interfaceService.request.imagedata = signatureImageData;
				_interfaceService.request.practicing = practicing;
				_interfaceService.request.userid = userid;
				_interfaceService.request.token = token;
				_interfaceService.resultFormat = 'text';
				_interfaceService.method = 'POST';
				if(!suppressEvent){
					_interfaceService.addEventListener( ResultEvent.RESULT, submitAssessmentResultHandler );
				}else{
					_interfaceService.addEventListener( ResultEvent.RESULT, submitSuppressedResultHandler );
				}
				_interfaceService.addEventListener( FaultEvent.FAULT, handleFault );
				_currentFormID = formid;
				_currentStudentID = studentID;
				// execute the service
				_interfaceService.send();
			}else{
				trace('storing to cache');
				if(_io.setAnswerCacheAsCompletedButNotSubmitted(studentID, formid, userid, siteid, signatureImageData, overall_rating, additional_rating, comments)){
					dispatchEvent(new Event('SUBMIT_SUCCESS', true));
				}else{
					dispatchEvent(new eOSCEErrorEvent(eOSCEErrorEvent.EVENT, 'storing completed exam to cache failed', true));
				}
			}
		}
		
		/**
		 * manage the result
		 * @param e
		 * 
		 */		
		private function submitAssessmentResultHandler(e:ResultEvent):void{
			trace("submitAssessmentResultHandler says "+e.result.toString());
			_interfaceService.removeEventListener( ResultEvent.RESULT, submitAssessmentResultHandler );
			_interfaceService.removeEventListener( FaultEvent.FAULT, handleFault );
			try{
				var result:XML = XML(e.result);
				if(result.hasOwnProperty('error')){
					// if it's something already in teh system
					//if(result.error.toString=='student already assessed'){
					_io.removeAnswerCache(_currentStudentID, _currentFormID);
					dispatchEvent(new eOSCEErrorEvent(eOSCEErrorEvent.EVENT, result.error+': '+result.detail, true));
					//}else{
					//dispatchEvent(new eOSCEErrorEvent(eOSCEErrorEvent.EVENT, result.error+', '+result.detail, true));
				}
				
				
			}catch(err:Error){dispatchEvent(new eOSCEErrorEvent(eOSCEErrorEvent.EVENT, 'bad network result:'+e.result.toString(), true));}
			// clear up the cached exam
			if(_io.removeAnswerCache(_currentStudentID, _currentFormID)){
				dispatchEvent(new Event('SUBMIT_SUCCESS', true));
			}else{
				//?? profit?
			}
		}
		
		// this function is used to handle a r
		/**
		 * this function is used to handle a result from the submitAssessment function, but doesn't send teh SUBMIT_SUCCESS event, so it won't trigger anything in the main app
		 * @param e
		 * 
		 */		
		private function submitSuppressedResultHandler(e:ResultEvent):void{
			trace("submitSuppressedResultHandler says "+e.result.toString());
			_interfaceService.removeEventListener( ResultEvent.RESULT, submitSuppressedResultHandler );
			_interfaceService.removeEventListener( FaultEvent.FAULT, handleFault );
			var outstandingassessments:XMLList = _io.getUnfinishedExams();
			try{
				var result:XML = XML(e.result);
				if(result.hasOwnProperty('error')){
					trace('error is:'+result.error);
					if(result.error=='student already assessed'){
						trace('Removing cached exam:'+outstandingassessments[0]);
						if(_io.removeAnswerCache(outstandingassessments[0].studentid, outstandingassessments[0].examid, true)){
							dispatchEvent(new Event('SUPRESSED_SUBMIT_SUCCESS', true));
						}else{
							dispatchEvent(new eOSCEErrorEvent(eOSCEErrorEvent.EVENT, 'File IO error, '+result.detail, true));
						}
					}else{
						
						dispatchEvent(new eOSCEErrorEvent(eOSCEErrorEvent.EVENT, result.error+', '+result.detail, true));
					}
				}
			}catch(err:Error){dispatchEvent(new eOSCEErrorEvent(eOSCEErrorEvent.EVENT, 'bad network result:'+e.result.toString(), true));}
			// clear up the cached exam
			if(_io.removeAnswerCache(outstandingassessments[0].studentid, outstandingassessments[0].examid, true)){
				dispatchEvent(new Event('SUPRESSED_SUBMIT_SUCCESS', true));
			}else{
				
			}
		}
		
		// submit after coming online.
		
		private function submitOutstandingAssessments(e:Event=null):void{
			// get outstanding assessments
			if(this.hasEventListener('SUPRESSED_SUBMIT_SUCCESS')){
				this.removeEventListener('SUPRESSED_SUBMIT_SUCCESS', submitOutstandingAssessments);
			}
			var outstandingassessments:XMLList = _io.getUnfinishedExams();
			if(outstandingassessments.length()>0){
				var assessmentdata:String = '<data><answers>';
				for (var assessmentitem:Object in outstandingassessments[0].questiondata.children()){
					assessmentdata += '<answer><question_id>'+outstandingassessments[0].questiondata.children()[assessmentitem].id.toString() + '</question_id><value>' +outstandingassessments[0].questiondata.children()[assessmentitem].value.toString()+'</value><comment>' + outstandingassessments[0].questiondata.children()[assessmentitem].comment.toString()+ '</comment></answer>'; 
				}
				assessmentdata += '</answers></data>';
				/*			trace('incoming data is:'+outstandingassessments[0])
				trace('assessment data atring is:'+assessmentdata)*/
				this.addEventListener('SUPRESSED_SUBMIT_SUCCESS', submitOutstandingAssessments);
				this.submitAssessment(outstandingassessments[0].studentid, outstandingassessments[0].examid, outstandingassessments[0].userid, outstandingassessments[0].siteid, outstandingassessments[0].overall_rating, outstandingassessments[0].additional_rating, assessmentdata, outstandingassessments[0].overall_comments, outstandingassessments[0].signature, outstandingassessments[0].practicing, _io.readSetting('token'), true); 
			}
			
		}
		//
		
		/**
		 * handle a fault generated by a HTTPService operation
		 *  @param event
		 * */
		private function handleFault(event:FaultEvent):void {
			var _i:int = 0;
			//SkinnableAlert.show('fault:'+event.message);
			
			dispatchEvent(event);
			var __message:String = '';
			try{
				_interfaceService.removeEventListener( ResultEvent.RESULT, getExamsForUserResultHandler );
			}catch(e:Error){}
			try{
				_interfaceService.removeEventListener( ResultEvent.RESULT, logonResultHandler );
			}catch(e:Error){}
			
			try{
				_interfaceService.removeEventListener( ResultEvent.RESULT, checkTokenResultHandler );
			}catch(e:Error){}
			
			try{
				_interfaceService.removeEventListener( ResultEvent.RESULT, submitAssessmentResultHandler );
			}catch(e:Error){}
			
			_interfaceService.removeEventListener( FaultEvent.FAULT, handleFault );
		}
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		//Imagery functions- DEPRECATED AND NOT USED IN THIS APP
		// Basically they're leftovers from when I cloned this lib. Still kinda handy for reference though
		//
		///////////////////////////////////////////////////////////////////////////////////////////////////////
		
		//
		//Upload an image
		//
		
		// upload an image file
		
		private var fileRef:FileReference;
		
		private var request:URLRequest;
		
		private var urlLoader:URLLoader = new URLLoader();
		
		/**
		 *Uploads an image to a web service 
		 * @param filename
		 * @param imagedata
		 * @param userID
		 * @param recordID
		 * @param urnum
		 * @param label
		 * @param tags
		 * @param token
		 * 
		 */		
		public function uploadImage(filename:String, imagedata:ByteArray, userID:String = '', recordID:String = '', urnum:String = '', label:String = '', tags:String = '', token:String=""):void{
			//request = new URLRequest(_io.readSetting('functionpath')+"sunray4service.php");
			//	trace('request is'+_functionPath+"sunray4service.php");
			try {
				
				var urlRequest:URLRequest = new URLRequest();
				urlRequest.url = _io.readSetting('functionpath');
				trace('url is:'+_io.readSetting('functionpath'));
				var variables:Object = new Object();
				variables.urnum = urnum;
				variables.recordid = recordID;
				variables.description = label;
				variables.action='uploadsunbeam';
				variables.issunray='true';
				variables.token=token;
				trace(ObjectUtil.toString(variables));
				
				urlRequest.contentType = 'multipart/form-data; boundary=' + UploadPostHelper.getBoundary();
				urlRequest.method = URLRequestMethod.POST;
				urlRequest.data = UploadPostHelper.getPostData(filename, imagedata, variables, 'userfile');
				urlRequest.requestHeaders.push( new URLRequestHeader( 'Cache-Control', 'no-cache' ) );
				
				urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
				urlLoader.addEventListener(Event.COMPLETE, uploadimagecompletedatahandler);
				urlLoader.addEventListener(ProgressEvent.PROGRESS, handleProgress);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, imageioerrorhandler);
				urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				urlLoader.load(urlRequest);
			} catch (err:Error) {
				
				trace('uploadImage error:'+err.message);
				dispatchEvent(new UploadCompleteEvent(UploadCompleteEvent.COMPLETE, new XML('<data><error>Image upload failed</error><detail>uploadImage try failed'+'</detail><data>'), true));
				//	_upload_status = "ERROR: zero-byte file";
			}
		}
		
		private function uploadimagecompletedatahandler(e:Event):void{
			
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, imageioerrorhandler);
			urlLoader.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, uploadimagecompletedatahandler); 
			dispatchEvent(new UploadCompleteEvent(UploadCompleteEvent.COMPLETE, new XML('<data><error></error><detail>'+escape(urlLoader.data)+'</detail></data>'), true));
		}
		
		private function imageioerrorhandler(e:IOErrorEvent):void{
			trace('Web_Service_Interface.ioerrorhandler says:'+e.text);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, imageioerrorhandler);
			urlLoader.removeEventListener(Event.COMPLETE, uploadimagecompletedatahandler);
			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			dispatchEvent(new UploadCompleteEvent(UploadCompleteEvent.COMPLETE, new XML('<data><error>Image upload failed</error><detail>'+escape(e.text)+'</detail></data>'), true));
		}
		
		
		private function onSecurityError(e:SecurityErrorEvent):void{
			
			fileRef.removeEventListener(IOErrorEvent.IO_ERROR, imageioerrorhandler);
			fileRef.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, uploadimagecompletedatahandler);
			dispatchEvent(new UploadCompleteEvent(UploadCompleteEvent.COMPLETE, new XML('<data><error>Image upload failed</error><detail>security error</detail></data>'), true));
		}
		
		
		private function handleProgress(e:ProgressEvent):void{
			_percentLoaded = Math.ceil((e.bytesLoaded/e.bytesTotal)*100);
			dispatchEvent(new UploadProgressEvent(UploadProgressEvent.PROGRESS, _percentLoaded, true));
		}
		
		
		private var _percentLoaded:Number = 0;
		
		public function get percentLoaded():Number
		{
			return _percentLoaded;
		}
		
		public function set percentLoaded(value:Number):void
		{
			_percentLoaded = value;
		}
		
		
		
		
		
		
	}
}