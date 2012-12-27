package com.roxstudio.haxe.ui;

import nme.display.BitmapData;
import nme.display.Sprite;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.Vector;

class RoxNinePatch extends Sprite {

    public var hScale(default, null): Float;
    public var vScale(default, null): Float;
    public var data(default, null): RoxNinePatchData;
    public var marginLeft(get_marginLeft, null): Float;
    public var marginRight(get_marginRight, null): Float;
    public var marginTop(get_marginTop, null): Float;
    public var marginBottom(get_marginBottom, null): Float;

    public function new(data: RoxNinePatchData) {
        super();
        this.data = data;
        setScale(1.0);
    }

    public function setScale(hScale: Float, ?vScale: Null<Float>) : RoxNinePatch {
        if (vScale == null) vScale = hScale;
        this.hScale = hScale;
        this.vScale = vScale;
        var bmd = data.bitmapData;
        var w = bmd.width, h = bmd.height;
        var g = data.ninePatchGrid;
        var ngw = w * hScale - w + g.width;
        var ngh = h * vScale - h + g.height;
        var vts = new Vector<Float>();
        var hval = [0.0, g.x, g.x + ngw, w * hScale];
        var vval = [0.0, g.y, g.y + ngh, h * vScale];
        for (i in 0...4) {
            for (j in 0...4) {
                vts.push(hval[j]);
                vts.push(vval[i]);
            }
        }
        graphics.clear();
        graphics.beginBitmapFill(bmd, null, false, true);
        graphics.drawTriangles(vts, data.ids, data.uvs);
        graphics.endFill();
        return this;
    }

    public inline function setDimension(inWidth: Float, inHeight: Float) : RoxNinePatch {
        return setScale(inWidth / data.bitmapData.width, inHeight / data.bitmapData.height);
    }

    public inline function getContentRect() : Rectangle {
        var g = data.contentGrid, bmd = data.bitmapData;
        return new Rectangle(g.x, g.y, bmd.width * (hScale - 1) + g.width, bmd.height * (vScale - 1) + g.height);
    }

    private inline function get_marginLeft() : Float {
        return data.contentGrid.x;
    }

    private inline function get_marginRight() : Float {
        return data.bitmapData.width - data.contentGrid.right;
    }

    private inline function get_marginTop() : Float {
        return data.contentGrid.y;
    }

    private inline function get_marginBottom() : Float {
        return data.bitmapData.height - data.contentGrid.bottom;
    }

}
