//
//  InspectorView.swift
//  FontInspector
//
//  Created by Litherum on 11/5/14.
//  Copyright (c) 2014 Litherum. All rights reserved.
//

import Cocoa

class InspectorView : NSView {
    var string : String {
        didSet {
            setNeedsDisplayInRect(bounds)
        }
    }
    var font : NSFont! {
        didSet {
            setNeedsDisplayInRect(bounds)
        }
    }

    var layoutManager : NSLayoutManager
    
    override init() {
        string = ""
        layoutManager = NSLayoutManager()
        super.init()
    }

    required init?(coder: NSCoder) {
        string = ""
        layoutManager = NSLayoutManager()
        super.init(coder: coder)
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        if font == nil {
            return
        }
        let largeFont : NSFont! = NSFont(descriptor: font.fontDescriptor, size: font.pointSize * 10)
        let attributedString = NSAttributedString(string: string, attributes: [NSFontAttributeName: largeFont])
        let textStorage = NSTextStorage(attributedString: attributedString)
        let textContainer = NSTextContainer()
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        let glyphRange = layoutManager.glyphRangeForTextContainer(textContainer);
        let usedRect = layoutManager.usedRectForTextContainer(textContainer);
        let location = NSMakePoint(0, 0/*(bounds.width - usedRect.width) / 2, (bounds.height - usedRect.height) / 2*/)
        layoutManager.drawGlyphsForGlyphRange(glyphRange, atPoint: location)
        NSBezierPath(rect: NSOffsetRect(usedRect, location.x, location.y)).stroke()
    }
}