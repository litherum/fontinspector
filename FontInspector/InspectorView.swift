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
    
    override init() {
        string = ""
        super.init()
    }

    required init?(coder: NSCoder) {
        string = ""
        super.init(coder: coder)
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        if font == nil {
            return
        }

        let largeFont : CTFontRef = NSFont(descriptor: font.fontDescriptor, size: font.pointSize * 10)!
        let attributedString = NSAttributedString(string: string, attributes: [NSFontAttributeName: largeFont])
        let line = CTLineCreateWithAttributedString(attributedString)
        let context = NSGraphicsContext.currentContext()?.CGContext

        var typographicAscent : CGFloat = 0
        var typographicDescent : CGFloat = 0
        let typographicWidth = CGFloat(CTLineGetTypographicBounds(line, &typographicAscent, &typographicDescent, UnsafeMutablePointer<CGFloat>.null()))
        let typographicHeight = typographicAscent + typographicDescent
        let offset = NSMakeSize((bounds.size.width - typographicWidth) / 2, (bounds.size.height - typographicHeight) / 2 + typographicDescent)

        CGContextSetTextMatrix(context, CGAffineTransformIdentity)
        CGContextSetTextPosition(context, offset.width, offset.height)

        let imageBounds = CTLineGetImageBounds(line, context)
        var runImageBounds : [NSRect] = []
        var runTypographicBounds : [NSRect] = []
        var glyphBounds: [NSRect] = []
        var glyphPositions: [CGPoint] = []

        for run in CTLineGetGlyphRuns(line) as [CTRunRef] {
            var runAscent : CGFloat = 0
            var runDescent : CGFloat = 0
            let runWidth = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, UnsafeMutablePointer<CGFloat>.null()))
            let runHeight = runAscent + runDescent

            var runBounds = CTRunGetImageBounds(run, context, CFRangeMake(0, 0))
            var runOrigin = NSMakePoint(0, 0)
            CTRunGetPositions(run, CFRangeMake(0, 1), &runOrigin)

            runImageBounds.append(NSOffsetRect(runBounds, runOrigin.x, runOrigin.y))
            let typographicRect = NSMakeRect(runOrigin.x, runOrigin.y - runDescent, runWidth, runHeight)
            runTypographicBounds.append(NSOffsetRect(typographicRect, offset.width, offset.height))

            let runFont = (CTRunGetAttributes(run) as NSDictionary)[kCTFontAttributeName as NSString] as NSFont!
            if runFont != nil {
                let glyphCount = CTRunGetGlyphCount(run)
                var glyphs = Array<CGGlyph>(count: glyphCount, repeatedValue: CGGlyph(0))
                glyphs.withUnsafeMutableBufferPointer({ (inout pointer : UnsafeMutableBufferPointer<CGGlyph>) in
                    CTRunGetGlyphs(run, CFRangeMake(0, 0), pointer.baseAddress)
                })
                var runGlyphPositions = Array<CGPoint>(count: glyphCount, repeatedValue: CGPointZero)
                runGlyphPositions.withUnsafeMutableBufferPointer({ (inout pointer : UnsafeMutableBufferPointer<CGPoint>) in
                    CTRunGetPositions(run, CFRangeMake(0, 0), pointer.baseAddress)
                })
                glyphPositions.extend(runGlyphPositions)
                var glyphBoundingRects = Array<CGRect>(count: glyphCount, repeatedValue: CGRectZero)
                glyphBoundingRects.withUnsafeMutableBufferPointer({ (inout pointer : UnsafeMutableBufferPointer<CGRect>) in
                    CTFontGetBoundingRectsForGlyphs(runFont, .OrientationDefault, glyphs, pointer.baseAddress, glyphCount)
                })
                for i in 0 ..< glyphCount {
                    glyphBoundingRects[i] = NSOffsetRect(glyphBoundingRects[i], runGlyphPositions[i].x, runGlyphPositions[i].y)
                    glyphBounds.append(NSOffsetRect(glyphBoundingRects[i], offset.width, offset.height))
                }
            }
        }
        glyphPositions = glyphPositions.map { CGPointMake($0.x + offset.width, $0.y + offset.height) }

        CTLineDraw(line, context)

        CGContextStrokeRect(context, imageBounds)

        for runImageBoundsRect in runImageBounds {
            CGContextStrokeRect(context, runImageBoundsRect)
        }

        for runTypographicBoundsRect in runTypographicBounds {
            CGContextStrokeRect(context, runTypographicBoundsRect)
        }

        for glyphBoundsRect in glyphBounds {
            CGContextStrokeRect(context, glyphBoundsRect)
        }

        /*glyphPositions.withUnsafeBufferPointer( { (pointer : UnsafeBufferPointer<CGPoint>) -> () in
            var address = pointer.baseAddress
            for i in 0 ..< glyphPositions.count - 1 {
                CGContextStrokeLineSegments(context, address, 2)
                address = address.successor()
            }
        })*/
        let positionRadius : CGFloat = 7
        for glyphPosition in glyphPositions {
            CGContextStrokeEllipseInRect(context, CGRectMake(glyphPosition.x - positionRadius / 2, glyphPosition.y - positionRadius / 2, positionRadius, positionRadius))
        }

        var typographicRect = NSMakeRect(0, -typographicDescent, typographicWidth, typographicHeight)
        typographicRect = NSOffsetRect(typographicRect, offset.width, offset.height)
        CGContextStrokeRect(context, typographicRect)

        var baselinePoints = [NSMakePoint(0, 0), NSMakePoint(typographicWidth, 0)]
        baselinePoints = baselinePoints.map() { NSMakePoint($0.x + offset.width, $0.y + offset.height) }
        CGContextStrokeLineSegments(context, baselinePoints, 2)

    }
}