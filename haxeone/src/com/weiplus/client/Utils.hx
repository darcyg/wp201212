package com.weiplus.client;

import nme.display.Bitmap;
import nme.display.BitmapData;

using com.roxstudio.haxe.ui.UiUtil;

class Utils {
    public function new() {
    }

    public static inline function smoothBmp(bmd: BitmapData) : Bitmap {
        return new Bitmap(bmd).rox_smooth();
    }
}
