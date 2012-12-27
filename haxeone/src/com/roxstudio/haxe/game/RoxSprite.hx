package com.roxstudio.haxe.game;

import nme.display.Sprite;

class RoxSprite extends Sprite {

    public var currentFrame: Int;
    public var currentScene: RoxScene;
    public var scenes: Array<RoxScene>;
    public var totalFrames: Int;

    public function new() {
        super();
    }

    public function gotoAndPlay(frameId: Int, ?scene: String) {

    }

    public function gotoAndStop(frameId: Int, ?scene: String) {

    }


}
