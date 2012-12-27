package com.roxstudio.haxe.ui;

import com.roxstudio.haxe.ui.UiUtil;
import nme.events.MouseEvent;
import flash.geom.Rectangle;
import nme.geom.Matrix;
import nme.display.GradientType;
import nme.display.Shape;
import nme.display.Bitmap;
import nme.geom.Point;
import com.roxstudio.haxe.ui.UiUtil;
import com.roxstudio.haxe.game.GameUtil;
import nme.display.DisplayObject;
import nme.text.TextField;
import nme.display.BitmapData;
import nme.display.Sprite;

using com.roxstudio.haxe.ui.UiUtil;

class RoxButton extends Sprite {

    public var anchor(default, set_anchor): Int;

//    public var icon: BitmapData;
//    public var label: TextField;
//    public var bg: RoxNinePatch;
//    public var textAlign: Int;
//    public var gap: Float;

    private static var defaultBg: RoxNinePatchData;

    private var bg: RoxNinePatch;
    private var content: DisplayObject;

    public function new(?width: Null<Float>, ?height: Null<Float>, ?anchor: Int = UiUtil.TOP_LEFT,
                        ?icon: Bitmap, ?label: TextField, ?bg: RoxNinePatch,
                        ?textAlign: Int = UiUtil.VCENTER, ?gap: Float = 4,
                        ?listener: Dynamic -> Void) {
        super();
        if (icon == null && label == null) throw "Cannot create an empty button.";
        content = label != null && icon != null ? group(icon, label, textAlign, gap) : label != null ? label : icon;
        if (bg == null) bg = getDefaultBg();
        this.bg = bg;
        var bgw = width != null ? width : content.width + bg.marginLeft + bg.marginRight;
        var bgh = height != null ? height : content.height + bg.marginTop + bg.marginBottom;
        this.bg.setDimension(bgw, bgh);
        addChild(this.bg);
        addChild(this.content);
        var hasListner = listener != null;
        if (hasListner) addEventListener(MouseEvent.CLICK, listener);
        mouseEnabled = hasListner;
        mouseChildren = !hasListner;
        set_anchor(anchor);
//        trace("w="+this.width+",h="+this.height+",cont_grid=" + bg.contentGrid.rox_rectStr() + ",content="+content.rox_dimension().rox_rectStr());
    }

    private function set_anchor(a: Int) : Int {
        this.anchor = a;
        var bgx = (a & 0x0F) == UiUtil.RIGHT ? -bg.width : (a & 0x0F) == UiUtil.HCENTER ? -bg.width / 2 : 0;
        var bgy = (a & 0xF0) == UiUtil.BOTTOM ? -bg.height : (a & 0xF0) == UiUtil.VCENTER ? -bg.height / 2 : 0;
        bg.rox_move(bgx, bgy);
        var r = bg.getContentRect();
        content.rox_move(bgx + r.x + (r.width - content.width) / 2, bgy + r.y + (r.height - content.height) / 2);
//        trace("bgx="+bgx+",bgy="+bgy+",r="+r.rox_rectStr()+",cont="+content.rox_dimension().rox_rectStr());
        return a;
    }

    private static function getDefaultBg() : RoxNinePatch {
        if (defaultBg == null) {
            var s = new Shape();
            var gfx = s.graphics;
            var mat = new Matrix();
            mat.createGradientBox(48, 48, GameUtil.PId2, 0, 0);
            gfx.beginGradientFill(GradientType.LINEAR, [ 0xCCFFFF, 0x33CCFF ], [ 1.0, 1.0 ], [ 0, 255 ], mat);
            gfx.lineStyle(2, 0x0099CC);
            gfx.drawRoundRect(1, 1, 46, 46, 16, 16);
            gfx.endFill();
            var bmd = new BitmapData(48, 48, true, 0);
            bmd.draw(s);
            defaultBg = new RoxNinePatchData(bmd, new Rectangle(8, 8, 32, 32));
        }
        return new RoxNinePatch(defaultBg);
    }

    private function group(i: Bitmap, t: TextField, align: Int, gap: Float) : DisplayObject {
        var sp = new Sprite();
        sp.addChild(i);
        sp.addChild(t);
        if ((align & 0xF0) != 0) { // horizotal layout
            align &= 0xF0;
            var w = i.width + t.width + gap, h = GameUtil.max(t.height, i.height);
            i.rox_move(0, align == UiUtil.VCENTER ? (h - i.height) / 2 : align == UiUtil.BOTTOM ? h - i.height : 0);
            t.rox_move(i.width + gap, align == UiUtil.VCENTER ? (h - t.height) / 2 : align == UiUtil.BOTTOM ? h - t.height : 0);
        } else { // vertical layout
            align &= 0x0F;
            var w = GameUtil.max(t.width, i.width), h = i.height + t.height + gap;
            i.rox_move(align == UiUtil.HCENTER ? (w - i.width) / 2 : align == UiUtil.RIGHT ? w - i.width : 0, 0);
            t.rox_move(align == UiUtil.HCENTER ? (w - t.width) / 2 : align == UiUtil.RIGHT ? w - t.width : 0, i.height + gap);
        }
        return sp;
    }

}
