package com.weiplus.client;

import com.roxstudio.haxe.ui.UiUtil;
import com.roxstudio.haxe.ui.RoxFlowPane;
import com.roxstudio.haxe.game.ResKeeper;
import com.roxstudio.haxe.game.ResKeeper;
import com.roxstudio.haxe.ui.RoxScreen;
import nme.geom.Rectangle;
import nme.display.Sprite;

using com.roxstudio.haxe.ui.UiUtil;

class BaseScreen extends RoxScreen {

    private static inline var DESIGN_WIDTH = 640;
    private static inline var TOP_HEIGHT = 86;
    private static inline var BTN_SPACING = 12;

    public var designWidth: Float; // always 640
    public var designHeight: Float;
    public var titleBar: Sprite;
    public var d2rScale: Float;
    public var content: Sprite;
    public var title: Sprite;
    public var btnBack: RoxFlowPane;
    public var hasBack: Bool = true;
    private var titleBtnOffsetL: Float;
    private var titleBtnOffsetR: Float;

    public function new() {
        super();
    }

    override public function onCreate() {
        super.onCreate();
        designWidth = DESIGN_WIDTH;
        d2rScale = screenWidth / designWidth;
        designHeight = screenHeight / d2rScale;
        titleBar = UiUtil.bitmap("res/bg_main_top.png");
        titleBtnOffsetL = BTN_SPACING;
        titleBtnOffsetR = titleBar.width - BTN_SPACING;
        if (title != null) {
            titleBar.addChild(title.rox_anchor(UiUtil.CENTER).rox_move(titleBar.width / 2, titleBar.height / 2));
        }
        titleBar.rox_scale(d2rScale);
        btnBack = UiUtil.button(UiUtil.TOP_LEFT, null, "返回", 0, 36, "res/btn_back.9.png", function(e) { finish(RoxScreen.CANCELED); } );
        if (hasBack) {
            addTitleButton(btnBack, UiUtil.LEFT);
        }
        content = createContent((designHeight - TOP_HEIGHT) * d2rScale);
        content.rox_move(0, TOP_HEIGHT * d2rScale);
        addChild(content);
        graphics.beginBitmapFill(ResKeeper.getAssetImage("res/bg_main.jpg"));
        graphics.drawRect(0, 0, screenWidth, screenHeight);
        graphics.endFill();
        addChild(titleBar);
    }

    public function addTitleButton(btn: RoxFlowPane, align: Int) {
        if (align == UiUtil.RIGHT) {
            btn.anchor = UiUtil.RIGHT | UiUtil.VCENTER;
            titleBar.addChild(btn.rox_move(titleBtnOffsetR, TOP_HEIGHT / 2));
            titleBtnOffsetR -= btn.width + BTN_SPACING;
        } else {
            btn.anchor = UiUtil.LEFT | UiUtil.VCENTER;
            titleBar.addChild(btn.rox_move(titleBtnOffsetL, TOP_HEIGHT / 2));
            titleBtnOffsetL += btn.width + BTN_SPACING;
        }
    }

    public inline function removeTitleButton(btn: RoxFlowPane) {
        titleBar.removeChild(btn);
        if (btn.anchor == UiUtil.RIGHT | UiUtil.VCENTER) {
            titleBtnOffsetR += btn.width + BTN_SPACING;
        } else {
            titleBtnOffsetL -= btn.width + BTN_SPACING;
        }
    }

    public function createContent(height: Float) : Sprite {
        return null;
    }

}
