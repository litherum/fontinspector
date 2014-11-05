//
//  GlyphTableCell.swift
//  FontInspector
//
//  Created by Litherum on 11/5/14.
//  Copyright (c) 2014 Litherum. All rights reserved.
//

import Cocoa

class GlyphTableCell: NSActionCell {
    let layoutManager : NSLayoutManager;

    override init() {
        layoutManager = NSLayoutManager()
        super.init()
    }

    required init(coder decoder: NSCoder) {
        layoutManager = NSLayoutManager()
        super.init(coder: decoder)
    }

    override func drawWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        if let chosenFont = font {
            let glyph : NSGlyph = NSGlyph(integerValue)
            let rect : NSRect = chosenFont.boundingRectForGlyph(glyph)
            println("\(integerValue) \(chosenFont.fontName) \(rect.origin.x) \(rect.origin.y) \(rect.size.width) \(rect.size.height)")
            var transform = NSAffineTransform()
            transform.scaleXBy(1, yBy: -1)
            NSAttributedString(string: "Hello", attributes: [NSFontAttributeName: chosenFont]).drawInRect(cellFrame)
            //layoutManager.showCGGlyphs([CGGlyph(glyph)], positions: [cellFrame.origin], count: 1, font: chosenFont, matrix: transform, attributes: nil, inContext: nil)
        }
    }
}