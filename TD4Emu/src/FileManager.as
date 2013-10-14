package 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	import flash.text.TextField;
    
    /**
     * ...
     * @author umhr
     */
    public class FileManager extends EventDispatcher
    {
        private var _tf:TextField;
		private var _fileReference:FileReference = new FileReference();
        public var data:String;
		public function FileManager():void 
        {
            
        }
		
		public function loadFile():void {
			_fileReference.browse();
			_fileReference.addEventListener(Event.SELECT, atSelect);
		}
		
		private function atSelect(e:Event):void 
		{
			_fileReference.removeEventListener(Event.SELECT, atSelect);
			_fileReference.addEventListener(Event.COMPLETE, atFileComplete);
			_fileReference.load();
		}
		
		private function atFileComplete(event:Event):void{
			_fileReference.removeEventListener(Event.COMPLETE, atFileComplete);
			data = event.target.data;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
        public function saveFile(text:String):void {
            var dat:String = text;
            
            dat = dat.replace(/\n/g, "\r\n");
            
            _fileReference.addEventListener(Event.COMPLETE, onComplete);
            _fileReference.save(dat, "data.td4"); // ダイアログを表示する
             
            function onComplete(e:Event):void
            {
				_fileReference.removeEventListener(Event.COMPLETE, onComplete);
            }
            
        }
		
        
    }
    
}