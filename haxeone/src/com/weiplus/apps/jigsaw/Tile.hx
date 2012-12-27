package com.weiplus.apps.jigsaw;

import nme.display.Bitmap;
import nme.display.Sprite;
import nme.display.BitmapData;
import nme.display.Shape;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.utils.ByteArray;
import nme.Vector;

using com.roxstudio.haxe.ui.UiUtil;

/**
 * ...
 * @author Rocks Wang
 */

class Tile extends Sprite {

    public var id: Int;
    public var angle: Int; // 0, 1, 2, 3 -> 0, 90, 180, 270
    public var sides: Array<Int>; // sideIdx = { top, right, bottom, left }, sides[sideIdx] = { 0, 1, 2, 3 -> none, plain, raised, hollow }
    public var sideLen: Float;
    public var maxLen: Float;
    public var colIndex: Int;
    public var rowIndex: Int;

    private var jigsaw: App;
    private var dirty: Bool;
    private var bmd: BitmapData;
    private var image: BitmapData;
    private var shape: BitmapData;

    public function new(inJigsaw: App, inColIndex: Int, inRowIndex: Int, inSides: Array<Int>, inAngle: Int) {
        super();
        jigsaw = inJigsaw;
        image = inJigsaw.image;
        shape = inJigsaw.shape;
        sideLen = inJigsaw.sideLen;
        maxLen = Std.int(shape.height / inJigsaw.shapeSideLen * sideLen);
        colIndex = inColIndex;
        rowIndex = inRowIndex;
        id = toId(colIndex, rowIndex);
        angle = 0;
        sides = inSides;
        angle = inAngle;
        var ml = Std.int(maxLen);
        bmd = new BitmapData(ml, ml);
        addChild(new Bitmap(bmd).rox_smooth().rox_move(-maxLen / 2, -maxLen / 2));
        update();
    }

    private function update() {
        var sl = sideLen, ml = maxLen;
        var r = new Rectangle(colIndex * sl - (ml - sl) / 2, rowIndex * sl - (ml - sl) / 2, ml, ml);
        var p = new Point(0, 0);
        if (r.x < 0) {
            p.x = -r.x - 1;
            r.width += r.x + 1;
            r.x = 0;
        }
        if (r.y < 0) {
            p.y = -r.y - 1;
            r.height += r.y + 1;
            r.y = 0;
        }
        if (r.right > image.width) {
            r.width -= r.right - image.width;
        }
        if (r.bottom > image.height) {
            r.height -= r.bottom - image.height;
        }
        bmd.copyPixels(image, r, p);
//		trace("r=" + RocUtils.rect2str(r) + ",p=" + RocUtils.point2str(p));

        var v = new Vector<Float>();
        var ii = new Vector<Int>();
        var uv = new Vector<Float>();
        var half = maxLen / 2;
        v.push(0);
        v.push(0);
        v.push(maxLen);
        v.push(0);
        v.push(half);
        v.push(half);
        v.push(maxLen);
        v.push(0);
        v.push(maxLen);
        v.push(maxLen);
        v.push(half);
        v.push(half);
        v.push(maxLen);
        v.push(maxLen);
        v.push(0);
        v.push(maxLen);
        v.push(half);
        v.push(half);
        v.push(0);
        v.push(maxLen);
        v.push(0);
        v.push(0);
        v.push(half);
        v.push(half);
        for (i in 0...12) ii.push(i);
        var uvoff = sides[0] * 0.25;
        uv.push(uvoff);
        uv.push(0);
        uv.push(uvoff + 0.25);
        uv.push(0);
        uv.push(uvoff + 0.125);
        uv.push(0.5);
        uvoff = sides[1] * 0.25;
        uv.push(uvoff + 0.25);
        uv.push(0);
        uv.push(uvoff + 0.25);
        uv.push(1);
        uv.push(uvoff + 0.125);
        uv.push(0.5);
        uvoff = sides[2] * 0.25;
        uv.push(uvoff + 0.25);
        uv.push(1);
        uv.push(uvoff);
        uv.push(1);
        uv.push(uvoff + 0.125);
        uv.push(0.5);
        uvoff = sides[3] * 0.25;
        uv.push(uvoff);
        uv.push(1);
        uv.push(uvoff);
        uv.push(0);
        uv.push(uvoff + 0.125);
        uv.push(0.5);
        var s = new Shape();
        var gfx = s.graphics;
        gfx.beginBitmapFill(shape, false, true);
        gfx.drawTriangles(v, ii, uv);
        gfx.endFill();
        var mask = new BitmapData(Std.int(ml), Std.int(ml), true, 0);
        mask.draw(s);

        var mbuf = mask.getPixels(new Rectangle(0, 0, ml, ml));
        var bbuf = bmd.getPixels(new Rectangle(0, 0, ml, ml));
        var obuf = UiUtil.rox_byteArray(mbuf.length);
        //mbuf.position = bbuf.position = 0;
        //trace(">>>>>mb=" + mbuf.bytesAvailable + ",len=" + mbuf.length + ",bb=" + bbuf.bytesAvailable + ",len=" + bbuf.length + ",pos=" + mbuf.position);
        for (i in 0...mbuf.length) {
            var mb = mbuf[i], bb = bbuf[i];// .readByte() & 0xFF, bb = bbuf.readByte() & 0xFF;
            if ((i & 0x3) == 0) { // alpha
                obuf[i] = mb; // obuf.writeByte(mb);
            } else if (mb > 100 && mb < 155) {
                obuf[i] = bb; // obuf.writeByte(bb);
            } else { // mb != 127
                var v = (bb * mb) >> 7;
                obuf[i] = v > 255 ? 255 : v;
            }
        }
        //obuf.position = 0;
        bmd.setPixels(new Rectangle(0, 0, ml, ml), obuf);
//        cast(this.getChildAt(0), Bitmap).bitmapData = mask;
    }

    override public function toString() : String {
        return "Tile(" + this.id + ")@" + new Point(x, y).rox_pointStr();
    }

    inline static public function toId(colIdx: Int, rowIdx: Int) : Int {
        return (colIdx << 16) + rowIdx;
    }

}