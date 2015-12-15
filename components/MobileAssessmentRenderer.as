package components
{
	import com.pialabs.eskimo.skins.mobile.ios.ButtonBarFirstButtonSkin;
	import com.pialabs.eskimo.skins.mobile.ios.ButtonBarLastButtonSkin;
	import com.pialabs.eskimo.skins.mobile.ios.ButtonSkin;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.controls.Spacer;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Image;
	import spark.components.Label;
	import spark.components.TextInput;
	import spark.components.ToggleButton;
	import spark.components.supportClasses.ItemRenderer;
	import spark.events.TextOperationEvent;
	import spark.primitives.Rect;
	import spark.skins.mobile.TextInputSkin;
	
	import au.com.clinman.events.MakeCommentEvent;
	import au.com.clinman.events.MarkQuestionEvent;
	import au.com.clinman.events.StartCommentEvent;
	import au.com.clinman.mobile.lib.CommentTextHolder;
	import au.edu.une.ruralmed.components.skins.AdamsTextInputSkin;
	import au.edu.une.ruralmed.components.skins.AltButtonSkin;
	
	import utils.string.htmlDecode;
	
	public class MobileAssessmentRenderer extends ItemRenderer 
	{
		// the assessment data object
		private var _data:XML;
		
		// the definition data object
		private var _scaleDefinition:XML;
		
		// the caret position. We need to set this everytime data is set because the TextOperationEvent.CHANGE seems to trigger something that
		// selects the text in the TextInput.
		private var _caretPosition:int = 0;
		
		// layout elements
		
		// the background
		private var _bgrect:Rect;
		
		// the layout of the renderer
		private var _hgroup:HGroup;
		
		private var _buttonGroup:HGroup = new HGroup();
		
		// display/data elements
		
		// the question text
		private var _label:Label;
		
		// a spacer
		private var _spacer:Spacer = new Spacer();;
		
		// the marking buttons
		private var _buttons:Array = new Array();
		
		// the comments field
		// a rectangle around the comment field
		private var _commentRect:Rect;
		
		// a thing to hold the comments field elements
		private var _commentContainer:Group;
		
		// a layout for the comment field elements
		private var _commentLayoutContainer:HGroup;
		
		// the comments field itself
		private var _commentField:Label;
		
		// a promptfor the comment field
		private var _makeCommentBut:Image;
		
		// a prompt for showing that this is an essential criteria  
		
		private var _isEssentialIndicator:Image;
		
		[Bindable]
		public var _commentTextObj:CommentTextHolder;
		
		private var _value:String = "";
		
		private var _i:int = 0;
		
		/*private var _buttonid:int = 0;*/
		
		private var _currentbuttonid:String = '';
		
		public function MobileAssessmentRenderer()
		{
			super();
			// some optimisation
			super.cacheAsBitmap = true;
			
			
			// set up background rectangle
			_bgrect = new Rect();
			this._bgrect.fill = new SolidColor(0xFFC8C8);
			this._bgrect.stroke = new SolidColorStroke(0xc0c0c0, 1, 1)
			this._bgrect.percentHeight = 100;
			this._bgrect.percentWidth = 100;
			this.addElement(_bgrect);
			
			// set up overall hgroup
			_hgroup = new HGroup();
			_hgroup.percentWidth = 100;
			_hgroup.verticalAlign = "middle";
			_hgroup.gap = 2;
			_hgroup.paddingTop = 5;
			_hgroup.paddingBottom = 5;
			this.addElement(_hgroup);
			// a little spacer
			_spacer.width = 4;
			_hgroup.addElement(_spacer);
			
			//  make a little essential indicator
			_isEssentialIndicator = new Image();
			_isEssentialIndicator.source= "icons/thin_alert_icon.png";
			
			// hide it
			_isEssentialIndicator.visible = false;
			_isEssentialIndicator.percentWidth = 0;
			
			_hgroup.addElement(_isEssentialIndicator);
			
			// set up label
			_label = new Label();
			this._label.maxDisplayedLines = -1;
			this._label.percentWidth = 30;
			this._label.setStyle('lineHeight', "100%");
			this._label.setStyle('lineBreak', "toFit");
			
			_hgroup.addElement(_label);
			
			// set up buttons container
			_buttonGroup.percentWidth = 35;
			_hgroup.addElement(_buttonGroup);
			
			
			// the comment field container
			_commentContainer = new Group();
			_commentContainer.percentHeight = 100;
			_commentContainer.percentWidth = 35;
			_hgroup.addElement(_commentContainer);
			
			// the rectangle
			_commentRect = new Rect();
			this._commentRect.stroke = new SolidColorStroke(0xa0a0a0, 1, 1)
			this._commentRect.percentHeight = 98;
			this._commentRect.percentWidth = 98;
			_commentContainer.addElement(_commentRect);
			
			// add a layout container
			_commentLayoutContainer = new HGroup();
			this._commentLayoutContainer.percentHeight = 98;
			this._commentLayoutContainer.percentWidth = 98;
			_commentContainer.addElement(_commentLayoutContainer);
			
			// the actual comments display
			_commentField = new Label();
			_commentField.percentWidth = 100;
			this._commentField.styleName = 'emojiCFFStyle';
			_commentLayoutContainer.addElement(_commentField);
			
			
			_makeCommentBut = new Image();
			_makeCommentBut.source= "icons/comment.png";
			_commentLayoutContainer.addElement(_makeCommentBut);
			
			// make the comments container *do* something
			_commentContainer.addEventListener(MouseEvent.CLICK, showCommentEntry)
		}
		
		
		
		override public function get data():Object
		{
			
			return _data;
		}
		
		private var _ratingScale:XMLList;
		
		private var _needs_comment_value:String = ""; 
		
		private var _invalidColour:SolidColor = new SolidColor(0xFFC8C8);
		private var _validColour:SolidColor = new SolidColor(0xC8FFC8);
		
		override public function set data(value:Object):void
		{
			
			this._data = XML(value);
			// accept definition
			if(!_ratingScale){
				_ratingScale = XMLList(Object(owner).parentDocument['currentExamRatingScaleList']);
				// set up buttons here
				if(_buttons.length<1){
					for each (var buttonDef : XML in _ratingScale) {
						_buttons.push(new ToggleButton());
						_buttons[_buttons.length-1].label = buttonDef.short_description;
						_buttons[_buttons.length-1].setStyle('skinClass', com.pialabs.eskimo.skins.mobile.ios.ButtonSkin);
						_buttons[_buttons.length-1].addEventListener(MouseEvent.CLICK, select);
						_buttons[_buttons.length-1].height = 40;
						_buttons[_buttons.length-1].percentWidth = (100/_ratingScale.length());
						_buttons[_buttons.length-1].id = (_buttons.length-1).toString();
						_buttonGroup.addElement(_buttons[_buttons.length-1]);
						
						if(buttonDef.needs_comment.toString()=='true'){
							_needs_comment_value = buttonDef.needs_comment.toString();
						}
						/*if(_buttons[_buttons.length-1].id == _currentbuttonid){
						_buttons[_buttons.length-1].selected = true;
						}*/
					}
				}
			}
			
			// set selected button 
			
			if(_data.hasOwnProperty('buttonid')){
				_currentbuttonid = data.buttonid;
				//trace('_currentbuttonid = '+_currentbuttonid);
				//_buttons[int(_currentbuttonid)].selected = true;
			}
			_buttons.forEach(togglebuttons);
			
			// set comments field feedback
			if(_data.hasOwnProperty('value')){	
				for(_i = 0; _i<_ratingScale.length(); _i++) {
					if(_ratingScale[_i].value == _data.value){
						_value = _ratingScale[_i].value;
						//_buttons[_i].selected = true;
						if(_needs_comment_value==_value.toString()){
							this._bgrect.fill = new SolidColor(0xFFC8C8);
						}
					}/*else{
					_buttons[_i].selected = false;
					}*/
					
				}
				
			}else{
				for(_i = 0; _i<_ratingScale.length(); _i++) {
					_buttons[_i].selected = false;
				}
			}
			
			
			
			_isEssentialIndicator.visible = false;
			_isEssentialIndicator.percentWidth = 0;
			this._label.percentWidth = 30;
			// is this essential? if so, show it
			if(_data.hasOwnProperty('type')){
				if(_data.type.toString()=='1'){
					_isEssentialIndicator.visible = true;
					_isEssentialIndicator.percentWidth = 2;
					this._label.percentWidth = 28;
					//trace('is essential');
				}
			}
			
			
			this._label.text = _data.text;
			
			// set comments
			if(_data.hasOwnProperty('comment')){
				this._commentField.text = htmlDecode(this._data.comment);
				//trace('set data says that comment text is:'+this._data.comment);
			}else{
				this._commentField.text = '';
			}
		
			
			// work out validity
			this.removeElement(_bgrect);
			if(this._data.hasOwnProperty('isvalid')){
				//trace('this thing has isvalid:'+this._data.isvalid);
				if(this._data.isvalid.toString()=='true'){
					this._bgrect.fill = _validColour;
				}else{
					this._bgrect.fill = _invalidColour;
					//trace('this thing is not valid');
				}
			}else{
				this._bgrect.fill = _invalidColour;
			}
			
			this.addElementAt(_bgrect,0);
		}
		
		
		// make the buttons work like a button bar 
		private function select(event:MouseEvent):void{
			
			_value = _ratingScale[_buttons.indexOf(event.target)].value;
			_currentbuttonid = event.target.id
			trace('value is:'+_value);
			// Make buttons toggle
			_buttons.forEach(togglebuttons);
			event.target.selected = true;
			dispatchEvent(new MarkQuestionEvent(MarkQuestionEvent.EVENT, _data.id, _value, _currentbuttonid, true));
		}
		
		private function togglebuttons(element:ToggleButton, index:Number, arr:Array):void {
			if(index.toString() == _currentbuttonid){
				element.selected = true;
			}else{
				element.selected = false;
			}
		}
		
		private function showCommentEntry(e:Event):void{
			
			dispatchEvent(new StartCommentEvent(StartCommentEvent.EVENT, _data.id, _data.comment, true));
		}
		
		//private function makeComment(event:TextOperationEvent):void{
		/*private function makeComment(event:Event):void{
		
		switch (_data.value.toString()) {
		case "0":
		//$("#comments_id_" + ($(this).attr('name').split('_'))[2]).css('background-color', 'rgba(255, 0, 0, 0.1)')
		if ((_commentField.text).length>0) {
		this._data.isvalid=='true'
		trace('Valid!:'+_commentField.text)
		this._bgrect.fill = new SolidColor(0xC8FFC8);
		}else{
		trace('Invalid!: value 0; text length'+_commentField.text.length)
		this._data.isvalid=='false'
		this._bgrect.fill = new SolidColor(0xFFC8C8);
		}
		break;
		case "1":
		trace('Valid!:'+_commentTextObj.text)
		this._data.isvalid=='true'
		this._bgrect.fill = new SolidColor(0xC8FFC8);
		break;
		default:
		trace('Invalid!:'+_commentTextObj.text)
		this._data.isvalid=='false'
		this._bgrect.fill = new SolidColor(0xFFC8C8);
		break;
		};
		}
		
		
		private function finishComment(event:FocusEvent):void{
		trace('finishing comment');
		//dispatchEvent(new MakeCommentEvent(MakeCommentEvent.EVENT, _data.id, _commentField.text, true));
		}*/
	}
}