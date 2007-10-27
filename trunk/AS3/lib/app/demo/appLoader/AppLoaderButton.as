﻿// FIXME: animate tank tread spinning..

package app.demo.appLoader
{
	import com.touchlib.*;
	import app.demo.appLoader.*;
	
	import flash.events.*;
	import flash.geom.*;
	import flash.display.*;	
	import fl.controls.Button;
	import flash.text.*;
	import flash.net.*;
	
	dynamic public class AppLoaderButton extends Sprite
	{
		var buttonOverlay:MovieClip;
		var buttonImage:Loader;
		var apploader:AppLoader;
		var buttonDown:Boolean;
		var buttonLocked:Boolean;
		
		public var appDescription:String;

		var setPosX:Number = 0;
		var setPosY:Number = 0;
		public var appName:String;
		
		function AppLoaderButton(app:AppLoader, appname:String, desc:String)
		{			
			apploader = app;
			appName = appname;
			appDescription = desc;
			
			buttonOverlay = new ButtonOverlay();
			buttonImage = new Loader();
			buttonImage.x = 12;
			buttonImage.y = 12;
			buttonDown = false;
			buttonLocked = false;
			
			this.buttonMode = true;
			this.useHandCursor = true;			
			
			trace("Loading img " + "www/img/apps/" + appname + ".png");
			buttonImage.load(new URLRequest("www/img/apps/" + appname + ".png"));
			
			addChild(buttonImage);
			addChild(buttonOverlay);
			
			this.addEventListener(TUIOEvent.TUIO_MOVE, this.tuioMoveHandler);			
			this.addEventListener(TUIOEvent.TUIO_DOWN, this.tuioDownEvent);						
			this.addEventListener(TUIOEvent.TUIO_UP, this.tuioUpEvent);									
			this.addEventListener(TUIOEvent.TUIO_OVER, this.tuioRollOverHandler);									
			this.addEventListener(TUIOEvent.TUIO_OUT, this.tuioRollOutHandler);			
			
			this.addEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveHandler);									
			this.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDownEvent);															
			this.addEventListener(MouseEvent.MOUSE_UP, this.mouseUpEvent);	
			this.addEventListener(MouseEvent.ROLL_OVER, this.mouseRollOverHandler);
			this.addEventListener(MouseEvent.ROLL_OVER, this.mouseRollOutHandler);
			
			this.addEventListener(Event.ENTER_FRAME, this.frameUpdate);
			
		}
		
		public function setPos(px:Number, py:Number)
		{
			x = px;
			y = py;
			
			setPosX = x;
			setPosY = y;
		}
		
		public function lockInPlace()
		{
			buttonLocked = true;
		}
		
		public function unlock()
		{
			buttonLocked = false;
		}
		
		public function frameUpdate(e:Event)
		{
			if(!buttonDown && !buttonLocked)
			{
				this.x += (setPosX - x) * 0.5;
				this.y += (setPosY - y) * 0.5;
			}
			
		}
		
		public function tuioDownEvent(e:TUIOEvent)
		{		
		
			if(buttonLocked)
				return;

			TUIO.listenForObject(e.ID, this);
			buttonDown = true;
			buttonOverlay.gotoAndStop(2);
			e.stopPropagation();
		}

		public function tuioUpEvent(e:TUIOEvent)
		{		
			if(buttonLocked)
			{
				apploader.buttonUnlock(this);				
				return;	
			}

		
			buttonDown = false;
			buttonOverlay.gotoAndStop(1);
			apploader.buttonDropped(this);
			
			e.stopPropagation();
		}		

		public function tuioMoveHandler(e:TUIOEvent)
		{
			if(buttonDown && !buttonLocked)
			{
				var tuioobj:TUIOObject = TUIO.getObjectById(e.ID);							
				
				var localPt:Point = parent.globalToLocal(new Point(tuioobj.x, tuioobj.y));														
				activeX = localPt.x;
				activeY = localPt.y;
				
				this.x = activeX - this.width/2;
				this.y = activeY - this.height/2;
			}

			e.stopPropagation();			
		}
		
		public function tuioRollOverHandler(e:TUIOEvent)
		{
			
		}
		
		public function tuioRollOutHandler(e:TUIOEvent)
		{
			e.stopPropagation();			
		
		}			
		
		public function mouseDownEvent(e:MouseEvent)
		{		
			if(buttonLocked)
				return;		
		
			buttonDown = true;
			buttonOverlay.gotoAndStop(2);
		}
		
		public function mouseUpEvent(e:MouseEvent)
		{		
			if(buttonLocked)
			{
				apploader.buttonUnlock(this);				
				return;	
			}
				
			buttonDown = false;
			buttonOverlay.gotoAndStop(1);
			apploader.buttonDropped(this);


		}		

		public function mouseMoveHandler(e:MouseEvent)
		{
			if(buttonDown && !buttonLocked)
			{
				this.x = parent.mouseX - this.width/2;
				this.y = parent.mouseY - this.height/2;
			}
		}
		
		public function mouseRollOverHandler(e:MouseEvent)
		{
		}
		
		public function mouseRollOutHandler(e:MouseEvent)
		{

		
		}							

		

	}
}