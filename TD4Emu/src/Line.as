package  
{
	
	import com.bit101.components.CheckBox;
	import com.bit101.components.ComboBox;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author umhr
	 */
	public class Line extends Sprite 
	{
		private var _comboBox:ComboBox;
		private var _assemblerCodeList:Array = [];
		private var _operationCodeList:Array = [];
		private var _imList:Array = [];
		private var _items:Array = [];
		//private var _assemblerCodeLabel:Label;
		private var _instructionLabel:Label;
		private var _imBox:ComboBox;
		private var _checkBoxList:Array/*CheckBox*/ = [];
		private var _aruTimer:Timer = new Timer(1000 * 5, 1);
		private var _address:int = 0;
		private var _pmShape:Shape;
		
		public function Line(address:int) 
		{
			_address = address;
			init();
		}
		private function init():void 
		{
			if (stage) onInit();
			else addEventListener(Event.ADDED_TO_STAGE, onInit);
		}

		private function onInit(event:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onInit);
			// entry point
			
			setArray();
			addUI();
		}
		
		private function setArray():void 
		{
			_items.push("ADD A,Im (A += Im)", "ADD B,Im (B += Im)", "MOV A,Im (A = Im)", "MOV B,Im (B = Im)");
			_items.push("MOV A,B (A = B)", "MOV B,A (B = A)", "JMP Im (Imアドレスにジャンプ)", "JNC Im (Cが0の時Imアドレスにジャンプ)");
			_items.push("IN A (A = 入力ポート)", "IN B (B = 入力ポート)", "OUT B (出力ポート = B)", "OUT Im (出力ポート = Im)");
			
			//_assemblerCodeList.push("ADD A,Im", "ADD B,Im", "MOV A,Im", "MOV B,Im");
			//_assemblerCodeList.push("MOV A,B", "MOV B,A", "JMP Im", "JNC Im");
			//_assemblerCodeList.push("IN A", "IN B", "OUT B", "OUT Im");
			
			_operationCodeList.push("0000", "0101", "0011", "0111");
			_operationCodeList.push("0001", "0100", "1111", "1110");
			_operationCodeList.push("0010", "0110", "1001", "1011");
			
			var n:int = 16;
			for (var i:int = 0; i < n; i++) 
			{
				_imList.push((16 + i).toString(2).substr(1) + " (" + i + ")");
			}
		}
		
		private function addUI():void 
		{
			_pmShape = new Shape();
			_pmShape.graphics.beginFill(0xBBBBBB);
			_pmShape.graphics.drawRect(-8, -2, 572, 24);
			_pmShape.graphics.endFill();
			addChild(_pmShape);
			_pmShape.visible = false;
			
			_comboBox = new ComboBox(this, 0, 0, _items[0], _items);
			_comboBox.selectedIndex = 0;
			_comboBox.width = 240;
			_comboBox.addEventListener(Event.SELECT, setFormat);
			
			_imBox = new ComboBox(this, 250, 0, _imList[0], _imList);
			_imBox.selectedIndex = 0;
			_imBox.width = 80;
			_imBox.addEventListener(Event.SELECT, setFormat);
			
			_instructionLabel = new Label(this, 340, 0, _operationCodeList[0] + _imList[0].substr(0, 4));
			
			var n:int = 8;
			for (var i:int = 0; i < n; i++) 
			{
				_checkBoxList[i] = new CheckBox(this, 400 + i * 14, 5, "", onCBClick);
			}
			
			new Label(this, 530, 0, _address.toString());
			
			_aruTimer.addEventListener(TimerEvent.TIMER_COMPLETE, aruTimer_timerComplete);
		}
		
		private function aruTimer_timerComplete(e:TimerEvent):void 
		{
			_comboBox.selectedIndex = 0;
		}
		
		private function onCBClick(e:Event):void 
		{
			var str:String = "";
			var n:int = _checkBoxList.length;
			for (var i:int = 0; i < n; i++) 
			{
				str += _checkBoxList[i].selected?"1":"0";
			}
			
			var opCode:String = str.substr(0, 4);
			var imCode:String = str.substr(4);
			
			var isAru:Boolean;
			n = _operationCodeList.length;
			for (i = 0; i < n; i++) 
			{
				if (_operationCodeList[i] == opCode) {
					_comboBox.selectedIndex = i;
					isAru = true;
				}
			}
			
			_aruTimer.reset();
			if (!isAru) {
				_aruTimer.start();
			}else {
				_aruTimer.stop();
			}
			
			
			var imNum:int = parseInt(imCode, 2);
			if(_imBox.selectedIndex != imNum){
				_imBox.selectedIndex = imNum;
			}
			
		}
		
		private function setFormat(e:Event):void {
			var selectedIndex:int = _comboBox.selectedIndex;
			
			// MOV命令の際はImは0000
			if (_imBox.selectedIndex != 0 && (selectedIndex == 4 || selectedIndex== 5)) {
				_imBox.selectedIndex = 0;
				return;
			}
			
			var text:String = _operationCodeList[selectedIndex];
			selectedIndex = _imBox.selectedIndex;
			text += _imList[selectedIndex];
			text = text.substr(0, 8);
			_instructionLabel.text = text;
			
			var n:int = text.length;
			for (var i:int = 0; i < n; i++) 
			{
				_checkBoxList[i].selected = text.substr(i, 1) == "1";
			}
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function setInstruction(value:String):void {
			if (value.length != 8) {
				return;
			}
			var n:int = 8;
			for (var i:int = 0; i < n; i++) 
			{
				_checkBoxList[i].selected = value.substr(n - i - 1, 1) == "1";
			}
			
			onCBClick(null);
		}
		
		public function getInstruction():String {
			return _instructionLabel.text;
		}
		
		public function set isFocus(value:Boolean):void {
			_pmShape.visible = value;
		}
	}
	
}