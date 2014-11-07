//
//  AppDelegate.swift
//  FontInspector
//
//  Created by Litherum on 11/4/14.
//  Copyright (c) 2014 Litherum. All rights reserved.
//

import Cocoa

class StringCodepointsValueTransformer : NSValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSArray.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override func transformedValue(value: AnyObject?) -> AnyObject? {
        if let string = value as? String {
            var result : [CodepointNode] = []
            for codepoint in string.unicodeScalars {
                result.append(CodepointNode(codepoint: codepoint))
            }
            return result as NSArray
        }
        return nil
    }

    override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        if let array = value as? [CodepointNode] {
            var result = ""
            for codepoint in array {
                result.append(codepoint.codepoint)
            }
            return result
        }
        return nil
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var inspectorView: InspectorView!

    dynamic var font: NSFont! {
        didSet {
            NSFontManager.sharedFontManager().setSelectedFont(font, isMultiple: false)
            populate()
        }
    }

    dynamic var string : String {
        didSet {
            populate()
        }
    }
    var fontCodepoints: [PlaneNode]
    var fontGlyphs: [GlyphNode]
    var stringCodepoints: [CodepointNode]
    var stringGlyphs: [GlyphNode]

    var drawsLineBounds: Bool
    var drawsLineTypographicalBounds: Bool
    var drawsRunBounds: Bool
    var drawsRunTypographicalBounds: Bool
    var drawsGlyphBounds: Bool
    var drawsGlyphOrigins: Bool

    override init() {
        string = ""
        fontCodepoints = []
        fontGlyphs = []
        stringCodepoints = []
        stringGlyphs = []
        drawsLineBounds = true
        drawsLineTypographicalBounds = true
        drawsRunBounds = true
        drawsRunTypographicalBounds = true
        drawsGlyphBounds = true
        drawsGlyphOrigins = true
        super.init()
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        inspectorView.bind("string", toObject: self, withKeyPath: "string", options: nil)
        inspectorView.bind("font", toObject: self, withKeyPath: "font", options: nil)
        inspectorView.bind("drawsLineBounds", toObject: self, withKeyPath: "drawsLineBounds", options: nil)
        inspectorView.bind("drawsLineTypographicalBounds", toObject: self, withKeyPath: "drawsLineTypographicalBounds", options: nil)
        inspectorView.bind("drawsRunBounds", toObject: self, withKeyPath: "drawsRunBounds", options: nil)
        inspectorView.bind("drawsRunTypographicalBounds", toObject: self, withKeyPath: "drawsRunTypographicalBounds", options: nil)
        inspectorView.bind("drawsGlyphBounds", toObject: self, withKeyPath: "drawsGlyphBounds", options: nil)
        inspectorView.bind("drawsGlyphOrigins", toObject: self, withKeyPath: "drawsGlyphOrigins", options: nil)
        self.bind("stringCodepoints", toObject: self, withKeyPath: "string", options: [NSValueTransformerBindingOption: StringCodepointsValueTransformer()])
        string = "Hello, عالم!"
        font = NSFont(name: "American Typewriter", size: 12)
        populate()
        NSFontManager.sharedFontManager().target = self
    }

    override func changeFont(fontManager: AnyObject?) {
        if let fontManagerDowncast = fontManager as? NSFontManager {
            font = fontManagerDowncast.convertFont(font)
        }
    }

    func populate() {
        populateCodepoints()
        populateGlyphs()
        populateStringGlyphs()
    }

    func populateCodepoints() {
        willChange(.Replacement, valuesAtIndexes: NSIndexSet(indexesInRange: NSMakeRange(0, fontCodepoints.count)), forKey: "fontCodepoints")
        fontCodepoints.removeAll()
        if font != nil {
            let charset = font.coveredCharacterSet;
            for plane : UInt8 in 0 ... 16 {
                if !charset.hasMemberInPlane(plane) {
                    continue
                }
                let planeInt = UInt32(plane)
                var blocksInPlane : [BlockNode] = []
                var currentBlockCode : UBlockCode = UBLOCK_NO_BLOCK
                var currentCodepoints : [CodepointNode] = []
                for codepoint in planeInt * 1 << 16 ..< (planeInt + 1) * 1 << 16 {
                    if !charset.longCharacterIsMember(codepoint) {
                        continue
                    }
                    var block = ublock_getCode_53(UChar32(codepoint))
                    if block.value != currentBlockCode.value {
                        if currentCodepoints.count != 0 {
                            blocksInPlane.append(BlockNode(children: currentCodepoints, blockCode: currentBlockCode))
                            currentCodepoints = []
                        }
                        currentBlockCode = block
                    }
                    currentCodepoints.append(CodepointNode(codepoint: UnicodeScalar(codepoint)));
                }
                if currentCodepoints.count != 0 {
                    blocksInPlane.append(BlockNode(children: currentCodepoints, blockCode: currentBlockCode))
                }
                fontCodepoints.append(PlaneNode(children: blocksInPlane, plane: plane))
            }
        }
        didChange(.Replacement, valuesAtIndexes: NSIndexSet(indexesInRange: NSMakeRange(0, fontCodepoints.count)), forKey: "fontCodepoints")
    }

    func populateGlyphs() {
        willChange(.Replacement, valuesAtIndexes: NSIndexSet(indexesInRange: NSMakeRange(0, fontGlyphs.count)), forKey: "fontGlyphs")
        fontGlyphs.removeAll()
        if font != nil {
            for var glyph : NSGlyph = 0; fontGlyphs.count < font.numberOfGlyphs; ++glyph {
                let bbox = font.boundingRectForGlyph(glyph)
                if (bbox.origin.x > 0 || bbox.origin.y > 0 || bbox.size.width > 0 || bbox.size.height > 0) {
                    fontGlyphs.append(GlyphNode(glyph: glyph))
                }
                if Int(glyph) >= kCGGlyphMax {
                    break
                }
            }
        }
        didChange(.Replacement, valuesAtIndexes: NSIndexSet(indexesInRange: NSMakeRange(0, fontGlyphs.count)), forKey: "fontGlyphs")
    }

    func populateStringGlyphs() {
        willChange(.Replacement, valuesAtIndexes: NSIndexSet(indexesInRange: NSMakeRange(0, stringGlyphs.count)), forKey: "stringGlyphs")
        stringGlyphs.removeAll()
        if font != nil {
            let attributedString = NSAttributedString(string: string, attributes: [NSFontAttributeName: font])
            let line = CTLineCreateWithAttributedString(attributedString)
            var i : UInt = 0
            let runs = CTLineGetGlyphRuns(line) as NSArray
            for i in 0 ..< runs.count {
                let run = runs[i] as CTRunRef
                let runFont = (CTRunGetAttributes(run) as NSDictionary)[kCTFontAttributeName as NSString] as NSFont!
                let glyphCount = CTRunGetGlyphCount(run)
                var glyphs = Array<CGGlyph>(count: glyphCount, repeatedValue: CGGlyph(0))
                glyphs.withUnsafeMutableBufferPointer({ (inout pointer : UnsafeMutableBufferPointer<CGGlyph>) in
                    CTRunGetGlyphs(run, CFRangeMake(0, 0), pointer.baseAddress)
                })
                stringGlyphs.extend(glyphs.map() { GlyphDetailNode(glyph: NSGlyph($0), font: runFont, run: UInt(i)) })
            }
        }
        didChange(.Replacement, valuesAtIndexes: NSIndexSet(indexesInRange: NSMakeRange(0, stringGlyphs.count)), forKey: "stringGlyphs")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

