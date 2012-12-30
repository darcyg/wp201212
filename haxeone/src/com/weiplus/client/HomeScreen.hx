package com.weiplus.client;

import com.eclecticdesignstudio.motion.Actuate;
import nme.display.Bitmap;
import nme.display.BitmapData;
import com.roxstudio.haxe.game.ImageUtil;
import com.roxstudio.haxe.ui.RoxNinePatchData;
import com.roxstudio.haxe.ui.RoxNinePatch;
import com.roxstudio.haxe.ui.RoxFlowPane;
import com.roxstudio.haxe.ui.UiUtil;
import com.roxstudio.haxe.events.RoxGestureEvent;
import com.roxstudio.haxe.game.GameUtil;
import com.roxstudio.haxe.ui.RoxAnimate;
import com.roxstudio.haxe.ui.RoxApp;
import com.roxstudio.haxe.ui.RoxGestureAgent;
import com.roxstudio.haxe.ui.UiUtil;
import com.weiplus.client.model.User;
import com.weiplus.client.model.AppData;
import com.weiplus.client.model.Status;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.events.Event;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;

using com.roxstudio.haxe.ui.UiUtil;

class HomeScreen extends BaseScreen {

    private static inline var SPACING_RATIO = 1 / 40;

    var btnSingleCol: RoxFlowPane;
    var btnDoubleCol: RoxFlowPane;
    var btnCol: RoxFlowPane;
    var main: Sprite;
    var mainh: Float;
    var viewh: Float;
    var agent: RoxGestureAgent;
    var numCol: Int = 2;
    var postits: Array<Postit>;
    var animating: Bool = false;

    override public function onCreate() {
        title = UiUtil.bitmap("res/icon_logo.png");
        super.onCreate();
        btnCol = btnSingleCol = UiUtil.button("res/icon_single_column.png", null, "res/btn_common.9.png", onButton);
        addTitleButton(btnCol, UiUtil.RIGHT);
        btnDoubleCol = UiUtil.button("res/icon_double_column.png", null, "res/btn_common.9.png", onButton);
        agent = new RoxGestureAgent(content, RoxGestureAgent.GESTURE);
        content.addEventListener(RoxGestureEvent.GESTURE_PAN, onGesture);
        content.addEventListener(RoxGestureEvent.GESTURE_SWIPE, onGesture);
        content.addEventListener(RoxGestureEvent.GESTURE_TAP, onGesture);
        content.addEventListener(RoxGestureEvent.GESTURE_PINCH, onGesture);
    }

    override public function createContent(height: Float) : Sprite {
        var sp = new Sprite();

        main = new Sprite();
        update(2);
        sp.addChild(main);

        var btnNames = [ "icon_home", "icon_selected", "icon_maker", "icon_message", "icon_account" ];
        var btns: Array<DisplayObject> = [];
        for (b in btnNames) {
            var w = 126, h = 89;
            if (b == "icon_maker") w = 128;
            var button = new RoxFlowPane(w, h, [ UiUtil.bitmap("res/" + b + ".png") ], onButton);
            button.name = b;
            btns.push(button);
        }
        var bmd = ImageUtil.getBitmapData("res/bg_main_bottom.png");
        var npdata = new RoxNinePatchData(new Rectangle(0, 0, bmd.width, bmd.height), bmd);
        var btnpanel = new RoxFlowPane(null, null, UiUtil.LEFT | UiUtil.BOTTOM, btns,
                new RoxNinePatch(npdata), UiUtil.BOTTOM, [ 2 ]);
        sp.addChild(btnpanel.rox_scale(d2rScale).rox_move(0, height));
//        trace("btnpanel="+btnpanel.x+","+btnpanel.y+","+btnpanel.width+","+btnpanel.height);
        viewh = height - 95 * d2rScale;
        return sp;
    }

    private function update(numCol: Int) {
        if (agent != null) agent.stopScroll();
        var bmd1: BitmapData = null, sp1: Sprite = null;
        if (postits != null) {
            bmd1 = new BitmapData(Std.int(screenWidth), Std.int(viewh), true, 0);
            bmd1.draw(main, new Matrix(1, 0, 0, 1, 0, main.y));
            sp1 = new Sprite();
            sp1.addChild(new Bitmap(bmd1).rox_move(-bmd1.width / 2, -bmd1.height / 2));
        }
        this.numCol = numCol;
        var idx = 0;
        if (postits != null) {
            for (i in 0...postits.length) {
                var p = postits[i];
                if (p.y + main.y > 0) {
                    idx = i;
                    break;
                }
            }
        }
        main.rox_removeAll();
        var colh: Array<Float> = [];
        for (i in 0...numCol) colh.push(0);
        var spacing = screenWidth * SPACING_RATIO;
        var postitw = (screenWidth - (numCol + 1) * spacing) / numCol;
        var resetwidth = postits != null;
        if (postits == null) {
            postits = [];
            for (ss in statuses) {
                var status = new Status();
                status.user = new User();
                status.appData = new AppData();
                status.user.name = ss[0];
                status.user.profileImage = ss[1];
                status.appData.label = ss[2];
                status.appData.image = ss[3];
                var bmd = ImageUtil.loadBitmapData(ss[3]);
                status.appData.width = bmd.width;
                status.appData.height = bmd.height;
                status.text = ss[4];
                status.createdAt = Date.fromTime(Date.now().getTime() - Std.random(3600));
                var postit = new Postit(status, postitw, numCol == 1);
                postits.push(postit);
            }
        }
        var postity = 0.0;
        for (i in 0...postits.length) {
            var postit = postits[i];
            if (resetwidth) postit.setWidth(postitw, numCol == 1);
            var shadow = new RoxNinePatch(ImageUtil.getNinePatchData("res/shadow6.9.png"));
            shadow.setDimension(postitw + 3, postit.height + 6);

            var minh: Float = GameUtil.IMAX, colidx = 0;
            for (i in 0...colh.length) {
                if (colh[i] < minh) { minh = colh[i]; colidx = i; }
            }
            postit.rox_move(spacing + colidx * (postitw + spacing), minh + spacing);
            shadow.rox_move(postit.x - 2, postit.y);
            main.addChild(shadow);
            main.addChild(postit);
            colh[colidx] += postit.height + spacing;
            if (i == idx) {
                postity = postit.y;
            }
        }
        mainh = 0;
        for (i in 0...colh.length) {
            if (colh[i] > mainh) { mainh = colh[i]; }
        }
        mainh += spacing;

        main.y = spacing - postity;
        main.y = UiUtil.rangeValue(main.y, viewh - mainh, 0);

        if (sp1 != null) {
            animating = true;
            content.addChild(sp1.rox_move(bmd1.width / 2, bmd1.height / 2));
            if (numCol == 1) { // zoom in
                Actuate.tween(sp1, 0.4, { scaleX: 4, scaleY: 4, alpha: 0 }).onComplete(animDone, [ sp1 ]);
            } else {
                sp1.rox_scale(4);
                Actuate.tween(sp1, 0.4, { scaleX: 1, scaleY: 1, alpha: 0 }).onComplete(animDone, [ sp1 ]);
            }
        }
    }

    private inline function animDone(sp: DisplayObject) {
        content.removeChild(sp);
        animating = false;
    }

    private function onGesture(e: RoxGestureEvent) {
        if (animating) return;
        switch (e.type) {
            case RoxGestureEvent.GESTURE_TAP:
                for (i in 0...main.numChildren) {
                    var sp = main.getChildAt(i);
                    if (Std.is(sp, Postit)) {
                        trace("e=" + e + ",sp=("+sp.x+","+sp.y+","+sp.width+","+sp.height+")");
// TODO: in gestureagent, handle bubbled mouse/touch event, use currentTarget as owner?
                        var pt = main.localToGlobal(new Point(sp.x, sp.y));
                        if (GameUtil.pointInRect(e.stageX, e.stageY, pt.x, pt.y, sp.width, sp.height)) {
                            var postit: Postit = cast(sp);
                            var r = new Rectangle(pt.x, pt.y, sp.width, sp.height);
//                            startScreen(Type.getClassName(PostitScreen), new RoxAnimate(RoxAnimate.ZOOM_IN, r), postit.status);
                            return;
                        }
                    }
                }
            case RoxGestureEvent.GESTURE_PAN:
                main.y = UiUtil.rangeValue(main.y + e.extra.y, UiUtil.rangeValue(viewh - mainh, GameUtil.IMIN, 0), 0);
            case RoxGestureEvent.GESTURE_SWIPE:
                var desty = UiUtil.rangeValue(main.y + e.extra.y * 2.0, UiUtil.rangeValue(viewh - mainh, GameUtil.IMIN, 0), 0);
                agent.swipeScroll(main, 2.0, { y: desty });
            case RoxGestureEvent.GESTURE_PINCH:
//                trace("pinch:numCol=" + numCol + ",extra=" + e.extra);
                if (numCol > 1 && e.extra > 1) {
                    removeTitleButton(btnCol);
                    addTitleButton(btnCol = btnDoubleCol, UiUtil.RIGHT);
                    update(1);
                } else if (numCol == 1 && e.extra < 1) {
                    removeTitleButton(btnCol);
                    addTitleButton(btnCol = btnSingleCol, UiUtil.RIGHT);
                    update(2);
                }
        }
    }

    private function onButton(e: Event) {
        if (animating) return;
        trace("button " + e.target.name + " clicked");
        switch (e.target.name) {
            case "icon_single_column":
                removeTitleButton(btnCol);
                addTitleButton(btnCol = btnDoubleCol, UiUtil.RIGHT);
                update(1);
            case "icon_double_column":
                removeTitleButton(btnCol);
                addTitleButton(btnCol = btnSingleCol, UiUtil.RIGHT);
                update(2);
            case "icon_home":
//                startScreen(Type.getClassName(com.weiplus.client.TestGesture), new RoxAnimate(RoxAnimate.ZOOM_IN, new Rectangle(80, 80, 200, 300)));
            case "icon_selected":
            case "icon_maker":
//                startScreen(Type.getClassName(com.weiplus.client.RichEditor));
            case "icon_account":
//                startScreen(Type.getClassName(MakersScreen));
        }
    }

    private static var statuses = [
    [ "李开复", "res/avatar1.png", "苹果电视要来了?", "res/content1.jpg", "华尔街日报报道苹果和供应商富士康、夏普启动测试一款大屏幕高清电视。该报道认为苹果开始和供应商交流测试意味着内部产品和时间表可能已拟定。这款产品可能是60寸，仍需和运营商敲定合作方式。这款产品会再颠覆行业吗？能恢复对苹果股票的热情吗？" ],
    [ "王磊", "res/avatar1.png", "haXe为什么是更好的编程语言", "res/content2.jpg", "有了Type Inference大部分代码就像写动态语言那样简单，但是却是强类型的，编译器可以很容易的帮你发现错误。简单易用的泛型。using关键字让你的工具类更方便的使用" ],
    [ "郝晓伟", "res/avatar1.png", "快盘广告", "res/content3.jpg", "我刚刚拼的图" ],
    [ "伏英娜", "res/avatar1.png", "晴朗的天空", "res/image.jpg", "发发看看" ],
    [ "徐野", "res/avatar1.png", "IOS开发中", "res/content2.jpg", "这一刻，我有如爱因斯坦附体，灵感如长江流水连绵不绝！" ],
    [ "姚卫峰", "res/avatar1.png", "当Spring碰到Android", "res/content1.jpg", "他们会碰撞出什么样的火花？" ],
    [ "郑元吉", "res/avatar1.png", "这么长的微博你们见过没?", "res/content3.jpg", "纯粹就是测试下超长微博罢了。" ],
    [ "Christina", "res/avatar1.png", "Meet my best friend", "res/content1.jpg", "Is she beautiful?" ],
    [ "中兴手机", "res/avatar1.png", "转发微博送手机", "res/image.jpg", "木有乱七八糟的条件，转发微博即有机会获得iPad mini 哦，每天都开奖，直到全部送完" ],
    [ "AppStore", "res/avatar1.png", "Yet Another Top-10 APP!", "res/content1.jpg", "Take a look to this fantastic platform action game, it's smoothing, it's gailivable!" ]
    ];

}
