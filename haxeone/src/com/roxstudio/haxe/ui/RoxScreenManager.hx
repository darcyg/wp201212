package com.roxstudio.haxe.ui;

import com.roxstudio.haxe.game.ImageUtil;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.events.KeyboardEvent;
import com.roxstudio.haxe.ui.RoxAnimate;
import nme.Lib;
import com.eclecticdesignstudio.motion.Actuate;
import nme.geom.Rectangle;
import nme.display.Sprite;

class RoxScreenManager extends Sprite {

    private var screens: Hash<RoxScreen>;
    private var stack: Array<StackItem>;

    public function new() {
        super();
        screens = new Hash<RoxScreen>();
        stack = [];
        RoxApp.stage.addEventListener(KeyboardEvent.KEY_UP, function(e: KeyboardEvent) {
            if (e.keyCode == 27 && stack.length > 1) {
                var topscreen: RoxScreen = cast(getChildAt(0));
                if (topscreen.onBackKey()) {
                    finishScreen(topscreen, RoxScreen.CANCELED, null, null);
                    e.stopPropagation();
                }
            }
        });
    }

    public inline function addScreen(screen: RoxScreen) {
        var className = Type.getClassName(Type.getClass(screen));
        screens.set(className, screen);
    }

    public function startScreen(?source: RoxScreen, screenClassName: String, ?requestCode: Null<Int> = 1,
                                ?requestData: Dynamic, ?animate: RoxAnimate) {
        trace("startScreen,className=" + screenClassName);
        var dest = screens.get(screenClassName);
        if (dest == null) {
            ImageUtil.currentGroup = screenClassName;
            dest = Type.createInstance(Type.resolveClass(screenClassName), [ ]);
            dest.init(this, RoxApp.screenWidth, RoxApp.screenHeight);
//            trace("class=" + Type.resolveClass(screenClassName) + ",dest=" + dest);
            if (dest == null) throw "Unknown screenClassName: " + screenClassName;
            screens.set(screenClassName, dest);
            dest.onCreate();
        }
        if (animate == null) animate = RoxAnimate.SLIDE_LEFT;
        var request: Int = requestCode;
        stack.push({ className: screenClassName, requestCode: request, animate: animate });
        ImageUtil.currentGroup = screenClassName;
        dest.onNewRequest(requestData);
        if (source != null) {
            startAnimate(source, dest, animate);
        } else {
            dest.x = dest.y = 0;
            dest.alpha = dest.scaleX = dest.scaleY = 1;
            addChild(dest);
            dest.onFullyShown();
        }
    }

    public function finishScreen(screen: RoxScreen, resultCode: Int, resultData: Dynamic, animate: RoxAnimate) {
        var item = stack.pop();
        if (item.className != Type.getClassName(Type.getClass(screen)) || stack.length == 0) throw "Illegal stack state";
        animate = animate != null ? animate : item.animate.getReverse();
        var item = stack[stack.length - 1];
        var dest = screens.get(item.className);
        startAnimate(screen, dest, animate);
        dest.onScreenResult(item.requestCode, resultCode, resultData);
    }

    private function startAnimate(src: RoxScreen, dest: RoxScreen, anim: RoxAnimate) {
        addChild(dest);
        var srcsp = new Sprite(), destsp = new Sprite();
        var srcbmd = new BitmapData(Std.int(src.screenWidth), Std.int(src.screenHeight));
        var destbmd = new BitmapData(srcbmd.width, srcbmd.height);
        srcbmd.draw(src);
        destbmd.draw(dest);
        srcsp.addChild(new Bitmap(srcbmd));
        destsp.addChild(new Bitmap(destbmd));
        addChild(srcsp);
        addChild(destsp);
//        trace("startAnim:"+anim);
        switch (anim.type) {
            case RoxAnimate.SLIDE:
                switch (cast(anim.arg, String)) {
                    case "up":
                        destsp.y = dest.screenHeight;
                    case "right":
                        destsp.x = -dest.screenWidth;
                    case "down":
                        destsp.y = -dest.screenHeight;
                    case "left":
                        destsp.x = dest.screenWidth;
                }
//                trace("dest:" + Type.getClassName(Type.getClass(dest))+",xy=" + dest.x +","+ dest.y+",sc="+dest.scaleX+",alpha="+dest.alpha);
                Actuate.tween(srcsp, anim.interval, { x: -destsp.x, y: -destsp.y });
                Actuate.tween(destsp, anim.interval, { x: 0, y: 0 }).onComplete(animDone, [ src, dest, srcsp, destsp ]);
            case RoxAnimate.ZOOM_IN: // popup
                var r: Rectangle = cast(anim.arg);
                destsp.scaleX = destsp.scaleY = r.width / dest.screenWidth;
                destsp.x = r.x;
                destsp.y = r.y;
//                trace("sc=" + r.width / RoxApp.screenWidth + ",x=" + r.x + ",y=" + r.y);
                destsp.alpha = 0;
//                src.visible = false;
                Actuate.tween(destsp, anim.interval, { x: 0, y: 0, scaleX: 1, scaleY: 1, alpha: 1 })
                        .onComplete(animDone, [ src, dest, srcsp, destsp ]);
            case RoxAnimate.ZOOM_OUT: // shrink
                this.swapChildrenAt(0, 1); // make sure srcsp is on top
                var r: Rectangle = cast(anim.arg);
                var scale = r.width / dest.screenWidth;
                Actuate.tween(srcsp, anim.interval, { x: r.x, y: r.y, scaleX: scale, scaleY: scale, alpha: 0.01 })
                        .onComplete(animDone, [ src, dest, srcsp, destsp ]);

        }
    }

    private inline function animDone(src: Dynamic, dest: Dynamic, srcsp: Dynamic, destsp: Dynamic) {
        cast(dest, RoxScreen).onFullyShown();
        var srcScreen = cast(src, RoxScreen);
        removeChild(srcScreen);
        srcScreen.onHidden();
        if (srcScreen.disposeAtFinish) {
            var classname = Type.getClassName(Type.getClass(srcScreen));
            screens.remove(classname);
            ImageUtil.disposeGroup(classname);
        }
        removeChild(cast(srcsp));
        removeChild(cast(destsp));
//        trace("dest:" + Type.getClassName(Type.getClass(dest))+",xy=" + dest.x +","+ dest.y+",sc="+dest.scaleX+",alpha="+dest.alpha);
    }

}

private typedef StackItem = {
    var className: String;
    var requestCode: Int;
    var animate: RoxAnimate;
}
