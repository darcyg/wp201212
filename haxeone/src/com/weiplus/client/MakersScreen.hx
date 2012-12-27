package com.weiplus.client;

import com.roxstudio.haxe.ui.UiUtil;
import com.roxstudio.haxe.ui.RoxApp;
import com.roxstudio.haxe.ui.RoxScreen;
import nme.display.Bitmap;
import nme.display.Sprite;

using com.roxstudio.haxe.ui.UiUtil;

class MakersScreen extends BaseScreen {

    override public function onCreate() {
        super.onCreate();
        var btnBack = new Sprite().rox_button("res/btnBack.png", "btnBack", onButton);
        addTitleButton(btnBack, 12, 12);
    }

    override public function createContent(designHeight: Float) : Sprite {
        var bg = new Sprite();
        var makers = [ "btnJigsawMaker", "btnSlideMaker", "btnSwapMaker" ];
        for (i in 0...makers.length) {
            var btn = new Sprite().rox_button("res/" + makers[i] + ".png", UiUtil.CENTER, onButton);
            var y = 176 * i;
            btn.rox_move(designWidth / 2, y + 176 / 2);
            bg.addChild(btn);
            bg.graphics.lineStyle(2, 0x070707);
            bg.graphics.moveTo(0, y + 172);
            bg.graphics.lineTo(designWidth, y + 172);
            bg.graphics.lineStyle(2, 0x555555);
            bg.graphics.moveTo(0, y + 174);
            bg.graphics.lineTo(designWidth, y + 174);
            bg.graphics.lineStyle();
        }
        bg.rox_scale(d2rScale);
        return bg;
    }

    private function onButton(e: Dynamic) {
        switch (e.target.name) {
            case "btnJigsawMaker":
                startScreen(Type.getClassName(com.weiplus.apps.jigsaw.App));
            case "btnSlideMaker":
                startScreen(Type.getClassName(com.weiplus.apps.slidepuzzle.App));
            case "btnSwapMaker":
                startScreen(Type.getClassName(com.weiplus.apps.swappuzzle.App));
            case "btnBack":
                finish(RoxScreen.CANCELED);
        }
    }

}
