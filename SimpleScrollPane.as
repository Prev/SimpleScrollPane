package kr.prev.controls
{
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	public class SimpleScrollPane extends Sprite
	{

		public static const ALWAYS:String = "always";
		public static const AUTO:String = "auto";
		public static const NONE:String = "none";

		public var delta:uint = 5;
		
		private var _verticalScrollBarDragging:Boolean = false;
		private var _horizontalScrollBarDragging:Boolean = false;
		
		private var _container:Sprite;
		private var _maskSprite:Sprite;

		private var _verticalScrollBar:Sprite;
		private var _horizontalScrollBar:Sprite;

		public var upStateColor:uint;
		public var overStateColor:uint;
		public var downStateColor:uint;

		private var _nowState:String;

		public var verticalScrollBarPolicy:String;
		public var horizontalScrollBarPolicy:String;

		
		public var lockVScrollBarX:Boolean = true;
		public var lockHScrollBarY:Boolean = true;
		
		
		private var _width:Number;
		private var _height:Number;
		
		
		public function get container():Sprite {
			return _container;
		}
		public function get verticalScrollBar():Sprite {
			return _verticalScrollBar;
		}
		public function get horizontalScrollBar():Sprite {
			return _horizontalScrollBar;
		}
		
		
		
		override public function get width():Number {
			return _width;
		}
		
		override public function set width(value:Number):void {
			_width = value;
			
			_container.graphics.clear();
			_container.graphics.drawRect(0, 0, _width, _height);
			
			_maskSprite.graphics.clear();
			_maskSprite.graphics.beginFill(0, 1);
			_maskSprite.graphics.drawRect(0, 0, _width, _height);
			_maskSprite.graphics.endFill();
		}
		
		
		
		override public function get height():Number {
			return _height;
		}
		
		override public function set height(value:Number):void {
			_height = value;
			
			_container.graphics.clear();
			_container.graphics.drawRect(0, 0, _width, _height);
			
			_maskSprite.graphics.clear();
			_maskSprite.graphics.beginFill(0, 1);
			_maskSprite.graphics.drawRect(0, 0, _width, _height);
			_maskSprite.graphics.endFill();
		}
		
		

		public function SimpleScrollPane(width:Number, height:Number, verticalScrollBarPolicy:String = "auto", horizontalScrollBarPolicy:String = "auto", upStateColor:uint=0xCCCCCC, overStateColor:uint=0xAAAAAA, downStateColor:uint=0x888888)
		{
			_container = new Sprite();
			_maskSprite = new Sprite();
			
			_verticalScrollBar = new Sprite();
			_horizontalScrollBar = new Sprite();
			
			this.upStateColor = upStateColor;
			this.overStateColor = overStateColor;
			this.downStateColor = downStateColor;
			
			this.verticalScrollBarPolicy = verticalScrollBarPolicy;
			this.horizontalScrollBarPolicy = horizontalScrollBarPolicy;
			
			_container.graphics.drawRect(0, 0, width, height);
			
			_maskSprite.graphics.beginFill(0, 1);
			_maskSprite.graphics.drawRect(0, 0, width, height);
			_maskSprite.graphics.endFill();
			
			
			_width = width;
			_height = height;
			
			
			_container.mask = _maskSprite;
			
			_updateScrollBars();
			
			addChild( _container );
			addChild( _maskSprite );
			addChild( _verticalScrollBar );
			addChild( _horizontalScrollBar );
			
			//addEventListener(Event.ADDED, _addedHandler);
			addEventListener(Event.ADDED_TO_STAGE, _addedToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, _removedFromStageHandler);
			
			addEventListener(Event.ENTER_FRAME, _enterFrameHandler);
		}
		
		
		/** 매 프레임 핸들러 **/
		private function _enterFrameHandler(e:Event):void {
			_updateScrollBars();
		}
		
		
		
		/** SimpleScrollPane이 addChild 되었을때 호출 **/
		private function _addedToStageHandler(e:Event):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, _$verticalScrollBarUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, _$verticalScrollBarWheelHandler );
			
			_verticalScrollBar.addEventListener(MouseEvent.MOUSE_DOWN, _$verticalScrollBarDownHandler);
			_verticalScrollBar.addEventListener(Event.ENTER_FRAME, _verticalScrollBarHadnler);
			
			
			stage.addEventListener(MouseEvent.MOUSE_UP, _$horizontalScrollBarUpHandler);
			
			_horizontalScrollBar.addEventListener(MouseEvent.MOUSE_DOWN, _$horizontalScrollBarDownHandler);
			_horizontalScrollBar.addEventListener(Event.ENTER_FRAME, _horizontalScrollBarHadnler);
		}
		
		
		/** SimpleScrollPane이 removeChild 되었을때 호출 **/
		private function _removedFromStageHandler(e:Event):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, _$verticalScrollBarUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, _$verticalScrollBarWheelHandler );
			
			_verticalScrollBar.removeEventListener(MouseEvent.MOUSE_DOWN, _$verticalScrollBarDownHandler);
			_verticalScrollBar.removeEventListener(Event.ENTER_FRAME, _verticalScrollBarHadnler);
			
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, _$horizontalScrollBarUpHandler);
			
			_horizontalScrollBar.removeEventListener(MouseEvent.MOUSE_DOWN, _$horizontalScrollBarDownHandler);
			_horizontalScrollBar.removeEventListener(Event.ENTER_FRAME, _horizontalScrollBarHadnler);
		}
		
		
		
		
		/** maskSprite의 width, height를 수정 **/
		private function _setMaskSpriteProperties($width:Number, $height:Number):void {
			_maskSprite.width = $width;
			_maskSprite.height = $height;
		}
		
		
		
		/** 스크롤바 자동 업데이트 **/
		private function _updateScrollBars():void {
			if (!stage) return;
			
			if (!_verticalScrollBarDragging && !_verticalScrollBar.hitTestPoint(stage.mouseX, stage.mouseY) )
				_updateVerticalScrollBar(upStateColor);
				
			else if (!_verticalScrollBarDragging && _verticalScrollBar.hitTestPoint(stage.mouseX, stage.mouseY) )
				_updateVerticalScrollBar(overStateColor);
				
			else if (_verticalScrollBarDragging)
				_updateVerticalScrollBar(downStateColor);
			
			
			
			
			if (!_horizontalScrollBarDragging && !_horizontalScrollBar.hitTestPoint(stage.mouseX, stage.mouseY) )
				_updateHorizontalScrollBar(upStateColor);
				
			else if (!_horizontalScrollBarDragging && _horizontalScrollBar.hitTestPoint(stage.mouseX, stage.mouseY) )
				_updateHorizontalScrollBar(overStateColor);
				
			else if (_horizontalScrollBarDragging)
				_updateHorizontalScrollBar(downStateColor);
				
			
		}
		
		
		
		
		
		
		
		/** verticalScrollBar 업데이트 **/
		private function _updateVerticalScrollBar($color:uint):void {
			
			if (!_verticalScrollBarDragging && lockVScrollBarX) _verticalScrollBar.x = _maskSprite.width;
			
			_verticalScrollBar.graphics.clear();
			_verticalScrollBar.graphics.beginFill($color, 1);
			
			switch (verticalScrollBarPolicy) {
				case ALWAYS :
					_verticalScrollBar.graphics.drawRoundRect( 0, 0, 5, _maskSprite.height / _container.height * _maskSprite.height , 10 );
				break;
				
				
				case AUTO :
					if (_container.height > _maskSprite.height)
						_verticalScrollBar.graphics.drawRoundRect( 0, 0, 5, _maskSprite.height / _container.height * _maskSprite.height , 10 );
				break;
				
				case NONE :
					
				break;
			}
			
			_verticalScrollBar.graphics.endFill();
			
		}
		
		
		
		/** verticalScrollBar y 위치 설정**/
		private function _verticalScrollBarHadnler(e:Event):void {
			
			var _yPosition:Number;
			
			if (_maskSprite.height - _verticalScrollBar.height <= 0)
				_yPosition = 0;
			else
				_yPosition = _verticalScrollBar.y * _maskSprite.height / (_maskSprite.height - _verticalScrollBar.height);
			
			
			if (_yPosition < 0) {
				_yPosition = 0;
				_verticalScrollBar.y = 0;
			}
			
			if (_yPosition > _maskSprite.height) {
				_yPosition = _maskSprite.height;
				_verticalScrollBar.y = _maskSprite.height - _verticalScrollBar.height;
			}
			
			if (_container.height < _maskSprite.height)
				_container.y = 0;
			else
				_container.y = -1 * _yPosition * (_container.height - _maskSprite.height) / _maskSprite.height;
			
			
		}
		
		
		
		/** verticalScrollBar 마우스 다운시 이벤트 **/
		private function _$verticalScrollBarDownHandler(e:MouseEvent):void {
			_verticalScrollBarDragging = true;
			_verticalScrollBar.startDrag( false, new Rectangle( _verticalScrollBar.x, 0, 0, _maskSprite.height - _verticalScrollBar.height ) );
		}
		
		
		
		/** verticalScrollBar 마우스 업시 이벤트 **/
		private function _$verticalScrollBarUpHandler(e:MouseEvent) {
			_verticalScrollBarDragging = false;
			_verticalScrollBar.stopDrag();
		}
		
		
		
		/** verticalScrollBar 마우스 휠시 이벤트 **/
		private function _$verticalScrollBarWheelHandler(e:MouseEvent) {
			if (!hitTestPoint( stage.mouseX ,  stage.mouseY ) ) {
				return;
			}
			_verticalScrollBar.y -= e.delta * delta;
			
			if (_verticalScrollBar.y - _maskSprite.y < 0) {
				_verticalScrollBar.y = _maskSprite.y; 
			}else if (_verticalScrollBar.y  > _maskSprite.height - _verticalScrollBar.height ) {
				_verticalScrollBar.y = _maskSprite.height - _verticalScrollBar.height;
			}
		}
		
		
		
		
		
		
		
		
		
		
		
		
		/** horizontalScrollBar 업데이트 **/
		private function _updateHorizontalScrollBar($color:uint):void {
			
			if (!_horizontalScrollBarDragging && lockHScrollBarY) _horizontalScrollBar.y = _maskSprite.height;
			
			_horizontalScrollBar.graphics.clear();
			_horizontalScrollBar.graphics.beginFill($color, 1);
			
			switch (horizontalScrollBarPolicy) {
				case ALWAYS :
					_horizontalScrollBar.graphics.drawRoundRect( 0, 0, _maskSprite.width / _container.width * _maskSprite.width, 5 , 10 );
				break;
				
				
				case AUTO :
					if (_container.width > _maskSprite.width)
						_horizontalScrollBar.graphics.drawRoundRect( 0, 0, _maskSprite.width / _container.width * _maskSprite.width, 5 , 10 );
				break;
				
				case NONE :
					
				break;
			}
			
			_horizontalScrollBar.graphics.endFill();
			
		}
		
		
		
		/** horizontalScrollBar y 위치 설정**/
		private function _horizontalScrollBarHadnler(e:Event):void {
			
			var _xPosition:Number;
			
			if (_maskSprite.width - _horizontalScrollBar.width <= 0)
				_xPosition = 0;
			else
				_xPosition = _horizontalScrollBar.x * _maskSprite.width / (_maskSprite.width - _horizontalScrollBar.width);
			
			
			if (_xPosition < 0) {
				_xPosition = 0;
				_horizontalScrollBar.x = 0;
			}
			
			if (_xPosition > _maskSprite.width) {
				_xPosition = _maskSprite.width;
				_horizontalScrollBar.x = _maskSprite.width - _horizontalScrollBar.width;
			}
			
			if (_container.width < _maskSprite.width)
				_container.x = 0;
			else
				_container.x = -1 * _xPosition * (_container.width - _maskSprite.width) / _maskSprite.width;
			
			
		}
		
		
		
		/** horizontalScrollBar 마우스 다운시 이벤트 **/
		private function _$horizontalScrollBarDownHandler(e:MouseEvent):void {
			_horizontalScrollBarDragging = true;
			_horizontalScrollBar.startDrag( false, new Rectangle( 0, _horizontalScrollBar.y, _maskSprite.width - _horizontalScrollBar.width, 0 ) );
		}
		
		
		
		/** horizontalScrollBar 마우스 업시 이벤트 **/
		private function _$horizontalScrollBarUpHandler(e:MouseEvent) {
			_horizontalScrollBarDragging = false;
			_horizontalScrollBar.stopDrag();
		}
		
		

	}

}
