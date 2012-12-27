package com.roxstudio.haxe.ui;

import nme.events.SecurityErrorEvent;
import nme.errors.SecurityError;
import nme.net.URLLoaderDataFormat;
import nme.display.DisplayObject;
import nme.display.Loader;
import nme.events.ProgressEvent;
import nme.events.IOErrorEvent;
import nme.events.Event;
import nme.net.URLRequest;
import nme.net.URLLoader;
import nme.display.BitmapData;

class RoxBitmapLoader {

    public static inline var LOADING = 1;
    public static inline var READY = 2;
    public static inline var ERROR = 3;

    public var url(default, null): String;
    public var status(default, null): Int = LOADING;
    public var progress(default, null): Float = 0.0; // 0.0~1.0
    public var bytesTotal(default, null): Float = 0.0;
    public var bitmapData: BitmapData;

    private var loader: URLLoader;
    private var notifyCallback: Void -> Void;

    public function new(url: String) {
        this.url = url;
        loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;
    }

    public function load(notifyCallback: Void -> Void) {
        this.notifyCallback = notifyCallback;
        try {
            loader.load(new URLRequest(url));
            loader.addEventListener(Event.COMPLETE, onComplete);
            loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
            loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
        } catch (e: SecurityError) {
            onError(e);
        }
    }

    private inline function onComplete(e: Dynamic) {
        status = READY;
        var ldr = new Loader();
        ldr.loadBytes(cast(loader.data));
        var dp = ldr.content;
        bitmapData = new BitmapData(Std.int(dp.width), Std.int(dp.height), true, 0);
        bitmapData.draw(dp);
        loader = null;
        notifyCallback();
    }

    private inline function onError(e: Dynamic) {
        status = ERROR;
        loader = null;
        notifyCallback();
    }

    private inline function onProgress(e: ProgressEvent) {
        status = LOADING;
        bytesTotal = e.bytesTotal;
        progress = e.bytesLoaded / bytesTotal;
    }

    public function dispose() {
        url = null;
        notifyCallback = null;
        bitmapData.dispose();
        bitmapData = null;
        loader = null;
    }

}
