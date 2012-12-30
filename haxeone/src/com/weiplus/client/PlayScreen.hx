package com.weiplus.client;

import nme.geom.Matrix;
import com.roxstudio.haxe.ui.UiUtil;
import com.roxstudio.haxe.ui.RoxFlowPane;
import com.roxstudio.haxe.game.ImageUtil;
import com.roxstudio.haxe.game.ImageUtil;
import com.roxstudio.haxe.ui.RoxScreen;
import nme.geom.Rectangle;
import nme.display.Sprite;

using com.roxstudio.haxe.ui.UiUtil;

class PlayScreen extends BaseScreen {

    private static inline var DESIGN_WIDTH = 640;
    private static inline var TOP_HEIGHT = 86;
    private static inline var BTN_SPACING = 12;

    override public function onCreate() {
        designWidth = DESIGN_WIDTH;
        d2rScale = screenWidth / designWidth;
        designHeight = screenHeight / d2rScale;
        titleBar = UiUtil.bitmap("res/bg_play_top.png");
        titleBtnOffsetL = BTN_SPACING;
        titleBtnOffsetR = titleBar.width - BTN_SPACING;
        if (title != null) {
            titleBar.addChild(title.rox_anchor(UiUtil.CENTER).rox_move(titleBar.width / 2, titleBar.height / 2));
        }
        titleBar.rox_scale(d2rScale);
        var viewh = (designHeight - TOP_HEIGHT) * d2rScale;
        content = createContent(viewh);
        content.rox_move(0, TOP_HEIGHT * d2rScale);
        contentBg(screenWidth, viewh);
        addChild(content);
        addChild(titleBar);
        var btnBack = UiUtil.button(UiUtil.TOP_LEFT, null, "返回", 0xFFFFFF, 36, "res/btn_dark.9.png", function(e) { finish(RoxScreen.CANCELED); } );
        addTitleButton(btnBack, UiUtil.LEFT);
    }

    public function contentBg(w: Float, h: Float) {
        var bmd = ImageUtil.getBitmapData("res/bg_play.jpg");
        var scalex = w / bmd.width, scaley = h / bmd.height;
        content.graphics.beginBitmapFill(bmd, new Matrix(scalex, 0, 0, scaley, 0, 0), false, false);
        content.graphics.drawRect(0, 0, w, h);
        content.graphics.endFill();
    }

}
