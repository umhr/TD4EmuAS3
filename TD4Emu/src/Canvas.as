package  
{
	
	import com.bit101.components.CheckBox;
	import com.bit101.components.ComboBox;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.RadioButton;
	import com.bit101.components.Style;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author umhr
	 */
	public class Canvas extends Sprite 
	{
		private var _registorA:Label;
		private var _registorB:Label;
		private var _cFlag:Label;
		private var _programCounter:Label;
		private var _clock:int = 0;
		private var _lineList:Array/*Line*/ = [];
		private var _input:Label;
		private var _input0:CheckBox;
		private var _input1:CheckBox;
		private var _input2:CheckBox;
		private var _input3:CheckBox;
		private var _output:Label;
		private var _timer:Timer = new Timer(1000, 0);
		private var _sion:SiONSound = new SiONSound();
		private var _beep:CheckBox;
		private var _rb0:RadioButton;
		private var _rb1:RadioButton;
		private var _rb2:RadioButton;
		
		public function Canvas() 
		{
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
			//Style.embedFonts = false;
			//Style.fontName = "PF Ronda Seven";
			//Style.fontSize = 12;
			_timer.addEventListener(TimerEvent.TIMER, timer_timer);
			
			setUI();
			
			//_sion.play();
			
		}
		
		private function timer_timer(e:TimerEvent):void 
		{
			onClock(null);
		}
		
		private function setUI():void 
		{
			new Label(this, 16, 16, "RegistorA : ");
			new Label(this, 16, 32, "RegistorB : ");
			new Label(this, 16, 48, "C Flag : ");
			new Label(this, 16, 64, "ProgramCounter : ");
			_registorA = new Label(this, 73, 16, "0000");
			_registorB = new Label(this, 73, 32, "0000");
			_cFlag = new Label(this, 73, 48, "0");
			_programCounter = new Label(this, 110, 64, "0000");
			// I/O
			new Label(this, 200, 16, "INP : ");
			_input = new Label(this, 243, 16, "0000");
			_input0 = new CheckBox(this, 280 + 14 * 3, 16 + 5, "", onInput);
			_input1 = new CheckBox(this, 280 + 14 * 2, 16 + 5, "", onInput);
			_input2 = new CheckBox(this, 280 + 14, 16 + 5, "", onInput);
			_input3 = new CheckBox(this, 280, 16 + 5, "", onInput);
			new Label(this, 200, 32, "OUTP : ");
			
			var lineShape:Shape = new Shape();
			lineShape.graphics.lineStyle(0, 0x000000);
			lineShape.graphics.moveTo(247, 47);
			lineShape.graphics.lineTo(247, 55);
			addChild(lineShape);
			
			_output = new Label(this, 243, 32, "0000");
			_beep = new CheckBox(this, 242, 56, "Beep");
			
			// Clock
			new Label(this, 400, 16, "Clock Generator");
			_rb0 = new RadioButton(this, 400, 36, "1Hz", false, onClockGen);
			_rb1 = new RadioButton(this, 400, 52, "10Hz", false, onClockGen);
			_rb2 = new RadioButton(this, 400, 68, "Manual --->", true, onClockGen);
			_rb0.groupName = _rb1.groupName = _rb2.groupName = "rb";
			
			new PushButton(this, 475, 64, "Clock", onClock);
			new PushButton(this, 475, 90, "Reset", onReset);
			
			new PushButton(this, 16, 520, "Load", onLoad);
			new PushButton(this, 126, 520, "Save", onSave);
			
			// Program Memory
			var pmShape:Shape = new Shape();
			pmShape.graphics.beginFill(0xDDDDDD);
			pmShape.graphics.drawRect(8, 115, 572, 394);
			pmShape.graphics.endFill();
			addChild(pmShape);
			
			new Label(this, 16, 95, "Program Memory");
			
			new Label(this, 100, 116, "Operation Code");
			new Label(this, 265, 116, "Immediate Data");
			new Label(this, 405, 116, "Instruction set");
			new Label(this, 530, 116, "Address");
			
			Style.embedFonts = false;
			Style.fontName = "PF Ronda Seven";
			Style.fontSize = 12;
			
			var n:int = 16;
			for (var i:int = 0; i < n; i++) 
			{
				var line:Line = new Line(i);
				line.x = 16;
				line.y = 137 + i * 23;
				addChild(line);
				_lineList.push(line);
			}
			setFocus();
		}
		
		private function onLoad(e:Event):void 
		{
			var filemgr:FileManager = new FileManager();
			filemgr.addEventListener(Event.COMPLETE, filemgr_complete);
			filemgr.loadFile();
			
		}
		
		private function filemgr_complete(e:Event):void 
		{
			var filemgr:FileManager = e.target as FileManager;
			var list:Array = filemgr.data.split("\r\n");
			
			for (var i:int = 0; i < 16; i++) 
			{
				var str:String = "";
				for (var j:int = 0; j < 8; j++) 
				{
					str += list[i * 8 + j];
				}
				_lineList[i].setInstruction(str);
			}
			
			_rb0.selected = list[128] == "#TRUE#";
			_rb1.selected = list[129] == "#TRUE#";
			_rb2.selected = list[130] == "#TRUE#";
			_beep.selected = list[131] == "1";
			onClockGen(null);
		}
		
		private function onSave(e:Event):void 
		{
			var filemgr:FileManager = new FileManager();
			
			var text:String = "";
			
			var n:int = _lineList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var str:String = _lineList[i].getInstruction();
				var m:int = str.length;
				for (var j:int = 0; j < m; j++) 
				{
					text += str.substr(m - j - 1, 1) + "\n";
				}
			}
			
			text += (_rb0.selected?"#TRUE#":"#FALSE#") + "\n";
			text += (_rb1.selected?"#TRUE#":"#FALSE#") + "\n";
			text += (_rb2.selected?"#TRUE#":"#FALSE#") + "\n";
			text += _beep.selected?"1":"0" + "\n\n";
			filemgr.saveFile(text);
		}
		
		private function onInput(e:Event):void 
		{
			var text:String = _input3.selected?"1":"0";
			text += _input2.selected?"1":"0";
			text += _input1.selected?"1":"0";
			text += _input0.selected?"1":"0";
			_input.text = text;
		}
		
		private function onReset(e:Event):void 
		{
			_clock = 0;
			_programCounter.text = "0000";
			_registorA.text = "0000";
			_registorB.text = "0000";
			_cFlag.text = "0";
			_output.text = "0000";
			setFocus();
		}
		
		private function onClockGen(e:Event):void 
		{
			
			_timer.reset();
			if (_rb0.selected) {
				_timer.delay = 1000;
				_timer.start();
			}else if (_rb1.selected) {
				_timer.delay = 100;
				_timer.start();
			}else {
				_timer.stop();
			}
		}
		
		private function onClock(e:Event):void 
		{
			if (_timer.running && e) {
				return;
			}
			
			var instruction:String = _lineList[_clock].getInstruction();
			var opCode:String = instruction.substr(0, 4);
			var imCode:String = instruction.substr(4);
			
			if(opCode != "1110"){
				_cFlag.text = "0";
			}
			
			operation(opCode, imCode);
			
			if(opCode == "1110"){
				_cFlag.text = "0";
			}
			
			_clock ++;
			_clock %= 16;
			
			outPutCheck();
			
			_programCounter.text = ("0000" + _clock.toString(2)).substr( -4);
			setFocus();
		}
		
		private function outPutCheck():void 
		{
			var text:String = _output.text;
			if (text.substr(0, 1) == "1" && _beep.selected) {
				_sion.play();
			}
			
		}
		
		private function setFocus():void 
		{
			var n:int = _lineList.length;
			for (var i:int = 0; i < n; i++) 
			{
				_lineList[i].isFocus = (_clock == i);
			}
		}
		
		private function operation(opCode:String, imCode:String):void {
			
			switch (opCode) 
			{
				case "0000":
					addA(imCode);
				break;
				case "0101":
					addB(imCode);
				break;
				case "0011":
					movA(imCode);
				break;
				case "0111":
					movB(imCode);
				break;
				case "0001":
					movAB();
				break;
				case "0100":
					movBA();
				break;
				case "1111":
					jmp(imCode);
				break;
				case "1110":
					jnc(imCode);
				break;
				case "0010":
					inA();
				break;
				case "0110":
					inB();
				break;
				case "1001":
					outB();
				break;
				case "1011":
					out(imCode);
				break;
				default:
			}
		}
		
		private function addA(imCode:String):void {
			var text:String = _registorA.text;
			var num:int = parseInt(text, 2) + parseInt(imCode, 2);
			text = "0000" + num.toString(2);
			text = text.substr( -4);
			_registorA.text = text;
			if(num > 15){
				_cFlag.text = "1";
			}
		}
		private function addB(imCode:String):void {
			var text:String = _registorB.text;
			var num:int = parseInt(text, 2) + parseInt(imCode, 2);
			text = "0000" + num.toString(2);
			text = text.substr( -4);
			_registorB.text = text;
			if(num > 15){
				_cFlag.text = "1";
			}
		}
		private function movA(imCode:String):void {
			_registorA.text = imCode;
		}
		private function movB(imCode:String):void {
			_registorB.text = imCode;
		}
		private function movAB():void {
			_registorA.text = _registorB.text;
		}
		private function movBA():void {
			_registorB.text = _registorA.text;
		}
		private function jmp(imCode:String):void {
			_clock = parseInt(imCode, 2) - 1;
		}
		private function jnc(imCode:String):void {
			if (_cFlag.text == "0") {
				jmp(imCode);
			}
		}
		private function inA():void {
			_registorA.text = _input.text;
		}
		private function inB():void {
			_registorB.text = _input.text;
		}
		private function outB():void {
			_output.text = _registorB.text;
		}
		private function out(imCode:String):void {
			_output.text = imCode;
		}
	}
	
}