//
//  AppDelegate.swift
//  FontInspector
//
//  Created by Litherum on 11/4/14.
//  Copyright (c) 2014 Litherum. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var inspectorView: InspectorView!

    dynamic var font: NSFont! {
        didSet {
            NSFontManager.sharedFontManager().setSelectedFont(font, isMultiple: false)
            populate()
        }
    }

    dynamic var string : String
    var fontCodepoints: [PlaneNode]
    var fontGlyphs: [GlyphNode]

    override init() {
        string = ""
        fontCodepoints = []
        fontGlyphs = []
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        inspectorView.bind("string", toObject: self, withKeyPath: "string", options: nil)
        inspectorView.bind("font", toObject: self, withKeyPath: "font", options: nil)
        string = "Hello, عالم"
        font = NSFont(name: "American Typewriter", size: 12)
        populate()
    }

    override func changeFont(fontManager: AnyObject?) {
        if let fontManagerDowncast = fontManager as? NSFontManager {
            font = fontManagerDowncast.convertFont(font)
        }
    }

    func populate() {
        populateCodepoints()
        populateGlyphs()
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
        willChange(.Insertion, valuesAtIndexes: NSIndexSet(indexesInRange: NSMakeRange(0, font.numberOfGlyphs)), forKey: "fontGlyphs")
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
        didChange(.Insertion, valuesAtIndexes: NSIndexSet(indexesInRange: NSMakeRange(0, font.numberOfGlyphs)), forKey: "fontGlyphs")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

