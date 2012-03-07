package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class FeedBackScreen extends MovieClip
	{
		public function FeedBackScreen() 
		{
			this.x = 700 / 2;
			this.y = 450 / 2;
			
			this.gotoAndStop("END");
		}
		
		private function closeScreen(e:MouseEvent):void 
		{
			this.play();
			dispatchEvent(new Event(Event.CLOSE, true));
		}
		
		public function openScreen():void
		{
			this.gotoAndStop("BEGIN");
			this.closeButton.addEventListener(MouseEvent.CLICK, closeScreen, false, 0, true);
		}
		
		public function setText(texto:String):void
		{
			openScreen();
			this.texto.text = texto;
		}
		
	}

}