package com.roxstudio.haxe.ui;

import com.roxstudio.haxe.ui.RoxNinePatchData;
import com.roxstudio.haxe.game.ImageUtil;
import nme.display.DisplayObjectContainer;
import nme.events.Event;
import nme.utils.ByteArray;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.events.MouseEvent;
import com.roxstudio.haxe.game.GameUtil;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObject;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;

class UiUtil {

    public static inline var LEFT = 0x1;
    public static inline var HCENTER = 0x2;
    public static inline var RIGHT = 0x3;
    public static inline var JUSTIFY = 0x4;
    public static inline var TOP = 0x10;
    public static inline var VCENTER = 0x20;
    public static inline var BOTTOM = 0x30;
    public static inline var TOP_LEFT = 0x11; // shortcut for TOP | LEFT
    public static inline var TOP_CENTER = 0x12; // shortcut for TOP | HCENTER
    public static inline var CENTER = 0x22; // shortcut for VCENTER | HCENTER
    public static inline var BOTTOM_CENTER = 0x32; // shortcut for BOTTOM | HCENTER

    private function new() { }

    /**
    * usage: var bmp = new Bitmap(bitmapdata).smooth();
    **/
    public static inline function rox_smooth(bmp: Bitmap) : Bitmap {
        bmp.smoothing = true;
        return bmp;
    }

    public static inline function rox_textFormat(format: TextFormat, color: Int, size: Float, ?hAlign: Null<Int> = LEFT) : TextFormat {
#if android
        format.font = new nme.text.Font("/system/fonts/DroidSansFallback.ttf").fontName;
#end
        format.color = color;
        format.size = Std.int(size);
        format.align = switch (hAlign & 0x0F) {
            case LEFT: TextFormatAlign.LEFT; case HCENTER: TextFormatAlign.CENTER;
            case RIGHT: TextFormatAlign.RIGHT; case JUSTIFY: TextFormatAlign.JUSTIFY; };
        return format;
    }

    private static var textfieldCanvas: BitmapData;

    public static function rox_label(tf: TextField, text: String, format: TextFormat, multiline: Bool, ?width: Null<Float>) : TextField {
        if (textfieldCanvas == null) {
            textfieldCanvas = new BitmapData(100, 300);
        }
        var ox = tf.x, oy = tf.y;
        tf.selectable = false;
        tf.mouseEnabled = false;
        tf.defaultTextFormat = format;
        tf.multiline = tf.wordWrap = multiline;
        if (width != null) tf.width = width;
        tf.x = tf.y = 0;
        tf.text = text;
        textfieldCanvas.draw(tf); // force textfield to update width & height
        if (width == null) tf.width = tf.textWidth + 5;
        tf.height = tf.textHeight + 5;
        tf.x = ox;
        tf.y = oy;
        return tf;
    }

    public static inline function rox_bitmap(bmpPath, ?anchor: Int = TOP_LEFT, ?smooth: Bool = true) : Sprite {
        var sp = new Sprite();
        sp.addChild(new Bitmap(ImageUtil.getBitmapData(bmpPath)));
        rox_anchor(sp, anchor);
        return sp;
    }

    public static function rox_button(?iconPath: String, ?text: String, ?fontColor: Int = 0, ?fontSize: Float = 24,
                                      ?textAlign: Int = VCENTER, ?ninePatchPath: String, ?anchor: Int = TOP_LEFT,
                                      ?listener: Dynamic -> Void) : RoxButton {
        var name = text;
        if (name == null) {
            var i1 = iconPath.lastIndexOf("/"), i2 = iconPath.lastIndexOf(".");
            name = iconPath.substr(i1 + 1, i2 - i1 - 1);
        }
        var bg = ninePatchPath != null ? new RoxNinePatch(ImageUtil.getNinePatchData(ninePatchPath)) : null;
        var icon = iconPath != null ? rox_smooth(new Bitmap(ImageUtil.getBitmapData(iconPath))) : null;
        var tf = text != null ? rox_label(new TextField(), text, rox_textFormat(new TextFormat(), fontColor, fontSize), false) : null;

        var sp = new RoxButton(null, null, anchor, icon, tf, bg, textAlign, listener);
        sp.name = name;
        return sp;
    }

    public static inline function rox_buttonWidth(sp: Sprite) : Float {
        return cast(sp.getChildAt(0), Bitmap).bitmapData.width;
    }

    public static inline function rox_buttonHeight(sp: Sprite) : Float {
        return cast(sp.getChildAt(0), Bitmap).bitmapData.height;
    }

    public static inline function rox_move(dp: DisplayObject, x: Float, y: Float) : DisplayObject {
        dp.x = x;
        dp.y = y;
        return dp;
    }

    public static inline function rox_anchor(sp: Sprite, anchor: Int) : Sprite {
        var w = sp.width / sp.scaleX, h = sp.height / sp.scaleY;
        var xoff = (anchor & 0x0F) == RIGHT ? -w : (anchor & 0x0F) == HCENTER ? -w / 2 : 0;
        var yoff = (anchor & 0xF0) == BOTTOM ? -h : (anchor & 0xF0) == VCENTER ? -h / 2 : 0;
        for (i in 0...sp.numChildren) {
            var c = sp.getChildAt(i);
            rox_move(c, c.x + xoff, c.y + yoff);
        }
        return sp;
    }

    public static inline function rox_scale(dp: DisplayObject, scalex: Float, ?scaley: Null<Float>) : DisplayObject {
        dp.scaleX = scalex;
        dp.scaleY = scaley != null ? scaley : scalex;
        return dp;
    }

    public static inline function rox_dimension(dp: DisplayObject) : Rectangle {
        return new Rectangle(dp.x, dp.y, dp.width, dp.height);
    }

    public static inline function rox_rectStr(r: Rectangle) : String {
        return "Rect(" + r.x + "," + r.y + "," + r.width + "," + r.height + ")";
    }

    public static inline function rox_pointStr(p: Point) : String {
        return "Point(" + p.x + "," + p.y + ")";
    }

    public static inline function rox_stopPropagation(event: Dynamic, ?immediate: Null<Bool> = false) {
#if cpp
        Reflect.setField(event, "nmeIsCancelled", true);
        if (immediate) Reflect.setField(event, "nmeIsCancelledNow", true);

#else
        event.stopPropagation();
        if (immediate) event.stopImmediatePropagation();
#end
    }

    public static inline function rox_removeAll(dpc: DisplayObjectContainer) {
        var count = dpc.numChildren;
        for (i in 0...count) {
            dpc.removeChildAt(count - i - 1);
        }
    }

    public static inline function rox_rangeValue<T: Float>(v: T, min: T, max: T) : T {
        return v < min ? min : v > max ? max : v;
    }

    public static inline function rox_byteArray(?length: Null<Int>) : ByteArray {
#if flash
        var bb = new ByteArray();
        if (length != null) bb.length = length;
        return bb;
#else
        return length != null ? new ByteArray(length) : new ByteArray();
#end
    }

}
