package com.roxstudio.haxe.game;

import nme.display.Graphics;

class GfxUtil {

    private function new() {
    }

    public static inline function rox_line(g: Graphics, ?thickness: Int = 1, color: Int, x1: Float, y1: Float, x2: Float, y2: Float) {
        g.lineStyle(thickness, color & 0xFFFFFF, (color >>> 24) / 255);
        g.moveTo(x1, y1);
        g.lineTo(x2, y2);
        g.lineStyle();
        return g;
    }

    public static inline function rox_fillRect(g: Graphics, color: Int, x: Float, y: Float, w: Float, h: Float) {
        g.beginFill(color & 0xFFFFFF, (color >>> 24) / 255);
        g.drawRect(x, y, w, h);
        g.endFill();
        return g;
    }

}
