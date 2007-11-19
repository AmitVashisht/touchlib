﻿// IDEA: use the ability to save animations as code somehow.. 
// IDEA: allow layer blending effects to be set

// TODO: 
// move buttons,dialog to topmost layer

// color palettes - hard code? take from kuler?
// Settings editor
// more shapes
// Layer editor - delete layer, hide/unhide layer, layer blend mode.. layer FX - blend / dropshadow.. 
// write more AI algo's..

// Make multitouchable - each finger is it's own swarm.. 

package app.demo.artgen
{
	import flash.display.*;
	import com.touchlib.*;
	import app.demo.artgen.*;
	import app.core.element.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	public class ArtGenMain extends MovieClip 
	{
		private var swarm:Swarm = null;

		private var curLayer:Sprite;
		private var layers:Array;
		
		private var settings:XML;
		
		private var dialog:SettingsDialog;

		public function ArtGenMain() 
		{
			trace("ArtGenCanvas Initialized");

			layers = new Array();
			
			var spr:Sprite = new Sprite();
			curLayer = spr;
			layers.push(spr);
			layerHolder.addChild(spr);
			
			swarm = new Swarm();
			layerHolder.addChild(swarm);
			
			swarm.setDrawingCanvas(spr);
			
			settings = <swarm>
							<swarmType>Boid2</swarmType>
							<numMembers>2</numMembers>
							<shape>Shape1.swf</shape>
							<scale>0.5</scale>
							<alpha>0.5</alpha>								
							<algorithm>
								<speed>10</speed>
								<turnRate>4</turnRate>
							</algorithm>
							<trail>
								<lifeTime>5000</lifeTime>
								<createDelay>2</createDelay>
								<scaleDecay>-0.01</scaleDecay>
								<alphaDecay>-0.01</alphaDecay>
								<rotationDecay>0.1</rotationDecay>									
							</trail>
							<modulators>

								
								
								<modulator>
									<type>random</type>
									<rate>16.0</rate>
									<dest>position</dest>
									<amount>0.1</amount>
								</modulator>
								
								<modulator>
									<type>random</type>
									<rate>32.0</rate>
									<dest>alpha</dest>
									<amount>0.4</amount>
								</modulator>									
								
							</modulators>
					</swarm>;
			
			swarm.setupInfo(settings);
			
			addEventListener(Event.ENTER_FRAME, frameUpdate, false, 0, true);
			addEventListener(Event.UNLOAD, unloadHandler, false, 0, true);
			btSaveLayer.addEventListener(MouseEvent.CLICK, saveLayerHandler, false, 0, true);
			btClearLayer.addEventListener(MouseEvent.CLICK, clearLayerHandler, false, 0, true);
			btSwarmSettings.addEventListener(MouseEvent.CLICK, editSettingsHandler, false, 0, true);
			
			addEventListener(Event.ADDED_TO_STAGE, addedHandler, false, 0, true);

			TUIO.init( this, 'localhost', 3000, '', true );			
			
			var tmpArray = new Array();
			tmpArray.push("item1");
			tmpArray.push("item2");			
			tmpArray.push("item3");			
			
			dialog = new SettingsDialog(settings, this);
			dialog.visible = false;

			addChild(dialog);
		}
		
		function applySettings()
		{
			swarm.setupInfo(dialog.getXML());
		}
		
		function addedHandler(e:Event)
		{
				stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);			
		}
		
		function editSettingsHandler(e:Event)
		{
			dialog.visible = true;
		}
		
		function saveLayerHandler(e:Event)
		{
			saveLayer();
		}
		
		function clearLayerHandler(e:Event)
		{
			clearLayer();
		}		
		
		public function saveLayer()
		{
			trace("save layer");
			curLayer.dispatchEvent(new Event("freeze"));
			curLayer.cacheAsBitmap = true;
			
			var spr:Sprite = new Sprite();
			curLayer = spr;
			layers.push(spr);			
			layerHolder.addChild(spr);
							
			swarm.setDrawingCanvas(spr);			
			
			swapChildren(spr, swarm);		// make sure swarm is on top.. 
			
		}
		
		
		public function clearLayer()
		{
			trace("save layer");
			curLayer.dispatchEvent(new Event("clear"));

			
		}		
		function keyboardHandler(k:KeyboardEvent)
		{
			trace("Keyboard handler");
			if(k.keyCode == Keyboard.ENTER)
			{
				saveLayer();
			}
		}
		
		public function frameUpdate(e:Event)
		{
			swarm.track(new Point(this.mouseX, this.mouseY));

			swarm.draw();

		}
		
		public function unloadHandler(e:Event)
		{
			removeEventListener(Event.ENTER_FRAME, frameUpdate);			
			
			btSaveLayer.removeEventListener(MouseEvent.CLICK, saveLayerHandler);
			btClearLayer.removeEventListener(MouseEvent.CLICK, clearLayerHandler);			
			removeEventListener(Event.ADDED_TO_STAGE, addedHandler);			
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);			
		}
	}
}