package com.weiplus.client;

import nme.display.BlendMode;
import com.roxstudio.haxe.game.GameUtil;
import nme.display.BlendMode;
import nme.geom.Rectangle;
import com.roxstudio.haxe.ui.RoxAnimate;
import com.roxstudio.haxe.game.GameUtil;
import com.roxstudio.haxe.ui.RoxApp;
import com.roxstudio.haxe.ui.RoxScreenManager;
import com.roxstudio.haxe.ui.RoxScreen;
import nme.geom.Point;
import com.eclecticdesignstudio.motion.easing.Elastic;
import com.eclecticdesignstudio.motion.Actuate;
import nme.geom.Matrix;
import nme.display.DisplayObject;
import nme.display.Bitmap;
import com.roxstudio.haxe.events.RoxGestureEvent;
import com.roxstudio.haxe.ui.RoxGestureAgent;
import nme.display.Sprite;

using com.roxstudio.haxe.ui.UiUtil;

class TestGesture extends RoxScreen {

    var contentOffset = 0.0;

    public function new() {
        super();
        var container = new Sprite();
        var titlebar = new Bitmap(GameUtil.loadBitmapData("res/titlebar.png")).rox_smooth();
        container.addChild(titlebar);
        var scale = screenWidth / titlebar.bitmapData.width;
        container.rox_scale(scale);

        var btnBack = new Sprite().rox_button("res/btnBack.png", onClick);
        btnBack.rox_move(titlebar.width - btnBack.width - 14, 14);
        container.addChild(btnBack);
        contentOffset = titlebar.bitmapData.height * scale;

//        graphics.beginBitmapFill(GameUtil.loadBitmapData("res/shape.png"), new Matrix(0.5, 0, 0, 0.5, 0, 0));//0xFFBBBB);
        graphics.beginFill(0xFFBBBB);
        graphics.drawRect(0, 0, screenWidth, screenHeight);
        graphics.endFill();

        var big = new Sprite();
        var bmp = new Bitmap(GameUtil.loadBitmapData("res/content1.jpg"));
        bmp.smoothing = true;
        bmp.x = -bmp.width / 2;
        bmp.y = -bmp.height / 2;
        big.addChild(bmp);
        big.name = "big";
        big.x = screenWidth / 2;
        big.y = screenHeight / 2;
        var agent = new RoxGestureAgent(big, RoxGestureAgent.GESTURE);
        big.addEventListener(RoxGestureEvent.TOUCH_BEGIN, onTouch);
        big.addEventListener(RoxGestureEvent.GESTURE_TAP, function(e) { trace(e); });
        big.rotation = 15;
        big.addEventListener(RoxGestureEvent.GESTURE_PAN, agent.getHandler());
        big.addEventListener(RoxGestureEvent.GESTURE_SWIPE, agent.getHandler());
        big.addEventListener(RoxGestureEvent.GESTURE_PINCH, agent.getHandler());
        big.addEventListener(RoxGestureEvent.GESTURE_ROTATION, agent.getHandler());
//        big.blendMode = BlendMode.OVERLAY;
        addChild(big);
        //big.scaleX = big.scaleY = 1.5;

        var small = new Sprite();
        small.name = "small";
        bmp = new Bitmap(GameUtil.loadBitmapData("res/content2.jpg"));
        bmp.smoothing = true;
        bmp.x = -bmp.width / 2;
        bmp.y = -bmp.height / 2;
        small.addChild(bmp);
        small.x = 0;
        small.y = 0;
        agent = new RoxGestureAgent(small, RoxGestureAgent.GESTURE);
        small.addEventListener(RoxGestureEvent.GESTURE_TAP, onTouch);
        small.addEventListener(RoxGestureEvent.GESTURE_PAN, agent.getHandler(2));
        small.addEventListener(RoxGestureEvent.GESTURE_PINCH, agent.getHandler());
        small.addEventListener(RoxGestureEvent.GESTURE_LONG_PRESS, onTouch);
        big.addChild(small);

        var shape = new Sprite().rox_button("res/shape.png", onClick).rox_move(-400, 200);
        shape.blendMode = BlendMode.HARDLIGHT;
        small.addChild(shape);

        addChild(container);
    }

    private function onClick(e) {
        finish(RoxScreen.OK);
    }

    private function onTouch(e: RoxGestureEvent) {
        var sp = cast(e.target, DisplayObject);
        switch (e.type) {
            case RoxGestureEvent.GESTURE_TAP:
                trace(">>tap: e=" + e);
                var oldscale = sp.scaleX;
                Actuate.tween(sp, 0.05, { scaleX: oldscale * 1.3, scaleY: oldscale * 1.3});
                Actuate.tween(sp, 0.35, { scaleX: oldscale, scaleY: oldscale }, false).ease(Elastic.easeOut).delay(0.05);
            case RoxGestureEvent.GESTURE_LONG_PRESS:
                var oldscale = sp.scaleX;
                Actuate.tween(sp, 0.05, { scaleX: oldscale * 1.3, scaleY: oldscale * 1.3});
                Actuate.tween(sp, 0.25, { scaleX: oldscale, scaleY: oldscale }, false).ease(Elastic.easeOut).delay(0.05);
                Actuate.tween(sp, 0.05, { scaleX: oldscale * 1.3, scaleY: oldscale * 1.3}, false).delay(0.3);
                Actuate.tween(sp, 0.25, { scaleX: oldscale, scaleY: oldscale }, false).ease(Elastic.easeOut).delay(0.35);
        }
    }

}
