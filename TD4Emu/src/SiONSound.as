package
{
	import org.si.sion.SiONData;
	import org.si.sion.SiONDriver;
	public class SiONSound
	{
		private var _sionDriver:SiONDriver = new SiONDriver();
		private var _kaeruData:SiONData;
		public function SiONSound()
		{
			// constructor code
			_kaeruData = _sionDriver.compile("t240 @v64 l32 o8 c");
			
		}
		public function play():void {
			_sionDriver.play(_kaeruData);
		}

	}

}