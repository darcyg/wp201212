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
        var w = data.clipRect.width, h = data.clipRect.height;
        var g = data.ninePatchGrid;
        graphics.clear();
        if (data.bitmapData != null) {
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
            graphics.beginBitmapFill(data.bitmapData, null, false, true);
            graphics.drawTriangles(vts, data.ids, data.uvs);
        } else { // fake-transparent background
            graphics.beginFill(0xFFFFFF, 0.005);
            graphics.drawRect(0, 0, w * hScale, h * vScale);
        }
        graphics.endFill();
        return this;
    }

    public inline function setDimension(inWidth: Float, inHeight: Float) : RoxNinePatch {
        return setScale(inWidth / data.clipRect.width, inHeight / data.clipRect.height);
    }

    public inline function getContentRect() : Rectangle {
        var g = data.contentGrid, c = data.clipRect;
        return new Rectangle(g.x, g.y, c.width * (hScale - 1) + g.width, c.height * (vScale - 1) + g.height);
    }

    private inline function get_marginLeft() : Float {
        return data.contentGrid.x;
    }

    private inline function get_marginRight() : Float {
        return data.clipRect.width - data.contentGrid.right;
    }

    private inline function get_marginTop() : Float {
        return data.contentGrid.y;
    }

    private inline function get_marginBottom() : Float {
        return data.clipRect.height - data.contentGrid.bottom;
    }

}
