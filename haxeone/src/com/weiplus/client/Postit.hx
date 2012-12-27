package com.weiplus.client;

import com.roxstudio.haxe.ui.RoxFlowPane;
import com.roxstudio.haxe.ui.RoxAsyncBitmap;
import neash.geom.Rectangle;
import com.roxstudio.haxe.game.GameUtil;
import com.roxstudio.haxe.game.ImageUtil;
import com.weiplus.client.model.Status;
import com.weiplus.client.model.Comment;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.text.TextField;
import nme.text.TextFormat;

using com.roxstudio.haxe.ui.UiUtil;

class Postit extends Sprite {

    private static inline var MIN_WIDTH = 150;
    private static inline var MIN_MARGIN = 5;
    private static inline var MARGIN_RATIO = 1 / 40;
    private static inline var MIN_SPACING = 2;
    private static inline var SPACING_RATIO = 1 / 40;
    private static inline var AVATAR_RATIO = 60 / 450; // 50x50 in 480x800 screen

    private static inline var TITLE_TEXT_RATIO = 4 / 30;
    private static inline var TEXT_RATIO = 1 / 10; // 32 -> 240
    private static inline var MAX_TITLE_TEXT_SIZE = 24;
    private static inline var MIN_TITLE_TEXT_SIZE = 14;
    private static inline var MAX_TEXT_SIZE = 18;
    private static inline var MIN_TEXT_SIZE = 12;

    private var image: RoxAsyncBitmap;
    private var playButton: RoxFlowPane;
    private var imageLabel: RoxFlowPane;

    private var userAvatar: RoxFlowPane;
    private var userLabel: TextField;
    private var dateLabel: TextField;
    private var textLabel: TextField;
    private var infoLabel: TextField; // numRetweets, numComments, numLikes etc.

    public var status: Status;

    public function new(inStatus: Status) {
        super();
        status = inStatus;
    }

    public function update(inWidth: Float, statusChanged: Bool) {
        if (image == null) {
            addChild(image = new Sprite());
            addChild(imageLabel = new TextField());
//            addChild(infoLabel = new TextField());
            addChild(userAvatar = new Sprite());
            addChild(userLabel = new TextField());
            addChild(dateLabel = new TextField());
            addChild(textLabel = new TextField());
            image.addChild(new Bitmap(ImageUtil.getBitmapData(status.appData.image)).rox_smooth());
            userAvatar.addChild(new Bitmap(ImageUtil.getBitmapData(status.user.profileImage)).rox_smooth());
        }
        trace("img="+image.width+","+image.height+",userAvatar="+userAvatar.width+","+userAvatar.height);
        if (width == inWidth && !statusChanged) return;
        var imgbmp = cast(image.getChildAt(0), Bitmap);
        var avatarbmp = cast(userAvatar.getChildAt(0), Bitmap);
        if (statusChanged) {
            imgbmp.bitmapData = ImageUtil.getBitmapData(status.appData.image);
            avatarbmp.bitmapData = ImageUtil.getBitmapData(status.user.profileImage);
        }
        var margin = inWidth * MARGIN_RATIO;
        if (margin < MIN_MARGIN) margin = MIN_MARGIN;
        var spacing = inWidth * SPACING_RATIO;
        if (spacing < MIN_SPACING) spacing = MIN_SPACING;

        var yoffset = margin;
        var contentw = inWidth - 2 * margin;
        var scale = contentw / imgbmp.bitmapData.width;
        if (scale > 1) scale = 1;
        var imgw = imgbmp.bitmapData.width * scale;
        var imgh = imgbmp.bitmapData.height * scale;
        image.rox_scale(scale).rox_move(margin + (contentw - imgw) / 2, yoffset);
        yoffset += imgh + spacing;

        var titletextsize = inWidth * TITLE_TEXT_RATIO;
        titletextsize = titletextsize > MAX_TITLE_TEXT_SIZE ? MAX_TITLE_TEXT_SIZE :
                        titletextsize < MIN_TITLE_TEXT_SIZE ? MIN_TITLE_TEXT_SIZE : titletextsize;
        var format = new TextFormat().textFormat(0, titletextsize, 2); // center
        imageLabel.rox_label(status.appData.label, format, false, contentw).rox_move(margin, yoffset);
        yoffset += imageLabel.height + spacing;

        var splitOffset = yoffset;
        yoffset += spacing;

        scale = inWidth * AVATAR_RATIO / avatarbmp.bitmapData.width;
        userAvatar.rox_scale(scale).rox_move(margin, yoffset);
        var avatarw = avatarbmp.bitmapData.width * scale;

        var textsize = inWidth * TEXT_RATIO;
        textsize = textsize > MAX_TEXT_SIZE ? MAX_TEXT_SIZE :
                textsize < MIN_TEXT_SIZE ? MIN_TEXT_SIZE : textsize;
        format = new TextFormat().textFormat(0x222222, textsize); // left (default)
        userLabel.staticText(status.user.name, format, false);
        userLabel.rox_move(margin + avatarw + spacing, yoffset + (avatarw - userLabel.height) / 2);
        format = new TextFormat().textFormat(0x222222, textsize);
        dateLabel.staticText("1分钟前", format, false);
        dateLabel.rox_move(inWidth - margin - dateLabel.width, yoffset + (avatarw - dateLabel.height) / 2);
        yoffset += avatarw + spacing / 2;

        var avatarSplitOffset = yoffset;
        yoffset += spacing / 2 + 2;

        format = new TextFormat().textFormat(0x111111, textsize);
        textLabel.staticText(status.text, format, true, contentw);
        textLabel.rox_move(margin, yoffset);
        var h = yoffset + textLabel.height + margin;

        graphics.beginFill(0xFFFFFF);
        graphics.drawRect(0, 0, inWidth, h);
        graphics.endFill();
        graphics.beginFill(0xDDDDDD);
        graphics.drawRect(0, splitOffset, inWidth, h - splitOffset);
        graphics.endFill();
        graphics.lineStyle(1, 0xCCCCCC);
        graphics.moveTo(0, avatarSplitOffset);
        graphics.lineTo(inWidth, avatarSplitOffset);
        graphics.lineStyle(1, 0xEEEEEE);
        graphics.moveTo(0, avatarSplitOffset + 1);
        graphics.lineTo(inWidth, avatarSplitOffset + 1);
        graphics.lineStyle();
        trace("w="+inWidth+",h="+h+",split="+splitOffset+",imgLabel="+imageLabel.height+",usrLabel="+userLabel.height+",txt="+textLabel.height);
    }

}
