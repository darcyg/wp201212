package com.weiplus.client;

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
import nme.display.Sprite;
import nme.events.Event;
import nme.filters.DropShadowFilter;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;

using com.roxstudio.haxe.ui.UiUtil;

class HomeScreen extends BaseScreen {

    var btnSingleCol: RoxFlowPane;
    var btnDoubleCol: RoxFlowPane;
    var main: Sprite;
    var mainh: Float;
    var viewh: Float;
    var agent: RoxGestureAgent;
    var numCol: Int = 2;

    override public function onCreate() {
        super.onCreate();
        btnSingleCol = new RoxFlowPane("res/btnSingleCol.png", UiUtil.TOP | UiUtil.RIGHT, onButton);
        addTitleButton(btnSingleCol, designWidth - 11, 11);
        btnDoubleCol = new Sprite().rox_button("res/btnDoubleCol.png", UiUtil.TOP | UiUtil.RIGHT, onButton);
        addTitleButton(btnDoubleCol, designWidth - 11, 11);
        btnDoubleCol.visible = false;
    }

    override public function createContent(height: Float) : Sprite {
        var sp = new Sprite();

        main = new Sprite();
        agent = new RoxGestureAgent(main, RoxGestureAgent.GESTURE);
        main.addEventListener(RoxGestureEvent.GESTURE_PAN, onGesture);
        main.addEventListener(RoxGestureEvent.GESTURE_SWIPE, onGesture);
        main.addEventListener(RoxGestureEvent.GESTURE_TAP, onGesture);
        main.addEventListener(RoxGestureEvent.GESTURE_PINCH, onGesture);
        update(2);
        sp.addChild(main);

        var btnpanel = new Sprite();
        var xoffset = 0.0;
        var btns = [ "btnHome", "btnSelected", "btnWrite", "btnMessage", "btnAccount" ];
        for (b in btns) {
            var button = new Sprite().rox_button("res/" + b + ".png", UiUtil.BOTTOM | UiUtil.LEFT, onButton);
            button.rox_move(xoffset, height / d2rScale);
            xoffset += button.rox_buttonWidth();
            btnpanel.addChild(button);
        }
        sp.addChild(btnpanel.rox_scale(d2rScale));

        viewh = height - (cast(btnpanel.getChildByName("btnWrite"), Sprite).rox_pixelHeight()) * d2rScale;
        return sp;
    }

    private function update(numCol: Int) {
        this.numCol = numCol;
        main.rox_removeAll();
        agent.stopScroll();
        main.y = 0;
        var colh: Array<Float> = [];
        for (i in 0...numCol) colh.push(0);
        var vspacing = screenWidth * 0.05 / numCol;
        var hspacing = numCol > 1 ? vspacing : 0;
        var postitw = screenWidth / numCol - numCol * hspacing;
        var shadow = new DropShadowFilter(4.0, 45.0, 0, 0.5); // alpha = 0.5
        for (ss in statuses) {
            var status = new Status();
            status.user = new User();
            status.appData = new AppData();
            status.user.name = ss[0];
            status.user.profileImage = ss[1];
            status.appData.label = ss[2];
            status.appData.image = ss[3];
            status.text = ss[4];
            var postit = new Postit(status);
            postit.update(postitw, false);
            if (numCol > 1) postit.filters = [ shadow ];
            main.addChild(postit);
            var minh: Float = GameUtil.IMAX, colidx = 0;
            for (i in 0...colh.length) {
                if (colh[i] < minh) { minh = colh[i]; colidx = i; }
            }
            postit.rox_move(colidx * (screenWidth / 2) + hspacing, minh + vspacing);
            colh[colidx] += postit.height + vspacing;
        }

        mainh = 0;
        for (i in 0...colh.length) {
            if (colh[i] > mainh) { mainh = colh[i]; }
        }
        mainh += vspacing;
//        main.graphics.beginFill(0xEEEEEE);
//        main.graphics.drawRect(0, 0, screenWidth, mainh + hspacing);
//        main.graphics.endFill();
//        main.rox_move(0, contentOffset);
    }

    private function onGesture(e: RoxGestureEvent) {
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
                            startScreen(Type.getClassName(PostitScreen), new RoxAnimate(RoxAnimate.ZOOM_IN, r), postit.status);
                            return;
                        }
                    }
                }
            case RoxGestureEvent.GESTURE_PAN:
                main.y = UiUtil.rangeValue(main.y + e.extra.y, UiUtil.rangeValue(viewh - mainh, GameUtil.IMIN, 0), 0);
            case RoxGestureEvent.GESTURE_SWIPE:
                var desty = UiUtil.rangeValue(main.y + e.extra.y * 2.0, UiUtil.rangeValue(viewh - mainh, GameUtil.IMIN, 0), 0);
                agent.swipeScroll(2.0, { y: desty });
            case RoxGestureEvent.GESTURE_PINCH:
                if (numCol > 1 && e.extra < 1) {
                    btnSingleCol.visible = false;
                    btnDoubleCol.visible = true;
                    update(1);
                } else if (numCol == 1 && e.extra > 1) {
                    btnSingleCol.visible = true;
                    btnDoubleCol.visible = false;
                    update(2);
                }
        }
    }

    private function onButton(e: Event) {
        trace("button " + e.target.name + " clicked");
        switch (e.target.name) {
            case "btnSingleCol":
                btnSingleCol.visible = false;
                btnDoubleCol.visible = true;
                update(1);
            case "btnDoubleCol":
                btnSingleCol.visible = true;
                btnDoubleCol.visible = false;
                update(2);
            case "btnHome":
                startScreen(Type.getClassName(com.weiplus.client.TestGesture), new RoxAnimate(RoxAnimate.ZOOM_IN, new Rectangle(80, 80, 200, 300)));
            case "btnSelected":
                var status = new Status();
                status.text = "【苹果电视要来了?】华尔街日报报道苹果和供应商富士康、夏普启动测试一款大屏幕高清电视。"
                        + "该报道认为苹果开始和供应商交流测试意味着内部产品和时间表可能已拟定。这款产品可能是60寸，仍需和运营商敲定合作方式。"
                        + "这款产品会再颠覆行业吗？能恢复对苹果股票的热情吗？";

                var appdata: AppData = status.appData = new AppData();
                appdata.label = "记录我的心情点滴";
                appdata.image = "res/content1.jpg";
                var user: User = status.user = new User();
                user.name = "李开复";
                user.profileImage = "res/avatar1.png";
                startScreen(Type.getClassName(com.weiplus.client.PostitScreen), new RoxAnimate(RoxAnimate.ZOOM_IN, new Rectangle(80, 80, 200, 300)), status);
            case "btnWrite":
                startScreen(Type.getClassName(com.weiplus.client.RichEditor));
            case "btnAccount":
                startScreen(Type.getClassName(MakersScreen));
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
