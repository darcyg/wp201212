package com.roxstudio.haxe.ui;

import nme.events.MouseEvent;
import com.roxstudio.haxe.game.ImageUtil;
import nme.display.Loader;
import nme.display.BitmapData;
import nme.events.Event;
import com.eclecticdesignstudio.spritesheet.Spritesheet;
import com.eclecticdesignstudio.spritesheet.AnimatedSprite;
import com.eclecticdesignstudio.spritesheet.data.BehaviorData;
import com.eclecticdesignstudio.spritesheet.data.SpritesheetFrame;
import nme.net.URLLoaderDataFormat;
import nme.net.URLRequest;
import nme.net.URLLoader;
import nme.display.Sprite;

class RoxAsyncBitmap extends Sprite {

    public var loaded: Bool = false;

    private static var loading: Spritesheet;

    private var loader: URLLoader;
    private var prevTime: Int;

    public function new(url: String, ?width: Null<Float>, ?height: Null<Float>) {
        super();
        loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        loader.load(new URLRequest(url));
        loader.addEventListener(Event.COMPLETE, complete);
        addEventListener(Event.ENTER_FRAME, update);
        addChild(getAnim());
    }

    private function complete(e) {
        trace("completed");
        var ldr = new Loader();
        ldr.loadBytes(cast(loader.data));
        loader.removeEventListener(Event.COMPLETE, complete);
        loader = null;
        removeEventListener(Event.ENTER_FRAME, update);
        removeChildAt(0);
        addChild(ldr.content);
        loaded = true;
    }

    private function getAnim() {
        if (loading == null) {
            loading = new Spritesheet(ImageUtil.getBitmapData("res/progress.png"));
            var frames: Array<Int> = [];
            for (i in 0...12) {
                loading.addFrame(new SpritesheetFrame(100 * i, 0, 100, 100));
                frames.push(i);
            }
            loading.addBehavior(new BehaviorData("loading", frames, true, 10, 0, 0));
        }
        var anim = new AnimatedSprite(loading);
        anim.showBehavior("loading");
        return anim;
    }

    private function update(e) {
        var currTime = nme.Lib.getTimer();
        var deltaTime: Int = currTime - prevTime;
        cast(getChildAt(0), AnimatedSprite).update(deltaTime);
        prevTime = currTime;
    }
}
