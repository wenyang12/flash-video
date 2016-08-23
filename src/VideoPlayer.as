package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.Security;
	
	public class VideoPlayer extends Sprite
	{
		private var src:String = '';
		private var onstart:String = '';
		private var onstop:String = '';
		private var loop:Boolean = false;
		private var connection:NetConnection;
		private var stream:NetStream;
		
		public function VideoPlayer()
		{
			Security.allowDomain('*');
			
			var params:Object = this.stage.loaderInfo.parameters;
			this.src = params.src || '';
			this.onstart = params.onstart || '';
			this.onstop = params.onstop || '';
			this.loop = params.loop === 'loop';
			
			if(this.stage) {
				this.addedToStage(null);
			} else {
				this.addEventListener(Event.ADDED_TO_STAGE, this.addedToStage);
			}
		}
		
		private function addedToStage(evt:Event):void {
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			evt && this.removeEventListener(Event.ADDED_TO_STAGE, this.addedToStage);
			
			if(this.stage.stageWidth === 0 || this.stage.stageHeight === 0) {
				this.stage.addEventListener(Event.RESIZE, this.onResize);
			} else {
				this.initialize();
			}
		}
		
		private function onResize(evt:Event):void {
			if(this.stage.stageWidth > 0 && this.stage.stageHeight > 0) {
				this.stage.removeEventListener(Event.RESIZE, this.onResize);
				this.initialize();
			}
		}
		
		private function initialize():void {
			
			if(!this.src) return;
			
			this.connection = new NetConnection();
			this.connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			this.connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			this.connection.connect(null);
		}
		
		private function netStatusHandler(evt:NetStatusEvent):void {
			switch(evt.info.code) {
				case "NetConnection.Connect.Success":
					this.connectStream();
					break;
				case "NetStream.Play.Start":
					this.onstart && ExternalInterface.call(this.onstart);
					break;
				case "NetStream.Play.Stop":
					this.onstop && ExternalInterface.call(this.onstop);
					this.loop && this.play();
					break;
			}
		}
		
		private function connectStream():void {
			this.stream = new NetStream(this.connection);
			this.stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			this.stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			
			var video:Video = new Video(this.stage.stageWidth, this.stage.stageHeight);
			video.attachNetStream(this.stream);
			this.addChild(video);
			
			this.play();
		}
		
		private function play():void {
			try {
				this.stream.play(this.src);
			}catch(e:Error){}
		}
		
		private  function securityErrorHandler(evt:SecurityErrorEvent):void {
		}
		
		private function asyncErrorHandler(evt:AsyncErrorEvent):void {
		}
		
		private function ieErrorHandler(evt:IOErrorEvent):void {
		}
	}
}