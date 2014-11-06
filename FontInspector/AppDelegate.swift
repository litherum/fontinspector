//
//  AppDelegate.swift
//  FontInspector
//
//  Created by Litherum on 11/4/14.
//  Copyright (c) 2014 Litherum. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var inspectorView: InspectorView!

    var font: NSFont!
    var string : String
    var codepoints: [PlaneNode]
    var glyphs: [GlyphNode]

    override init() {
        font = NSFont(name: "American Typewriter", size: 12);
        string = "Hello, World"
        codepoints = []
        glyphs = []
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        inspectorView.bind("string", toObject: self, withKeyPath: "string", options: nil)
        inspectorView.bind("font", toObject: self, withKeyPath: "font", options: nil)
        populate()
    }

    func populate() {
        if font == nil {
            return
        }
        populateCodepoints()
        populateGlyphs()
    }

    func populateCodepoints() {
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
            willChange(.Insertion, valuesAtIndexes: NSIndexSet(index: codepoints.count), forKey: "codepoints")
            codepoints.append(PlaneNode(children: blocksInPlane, plane: plane))
            didChange(.Insertion, valuesAtIndexes: NSIndexSet(index: codepoints.count), forKey: "codepoints")
        }
    }

    func populateGlyphs() {
        willChange(.Insertion, valuesAtIndexes: NSIndexSet(indexesInRange: NSMakeRange(0, font.numberOfGlyphs)), forKey: "glyphs")
        for var glyph : NSGlyph = 0; glyphs.count < font.numberOfGlyphs; ++glyph {
            let bbox = font.boundingRectForGlyph(glyph)
            if (bbox.origin.x > 0 || bbox.origin.y > 0 || bbox.size.width > 0 || bbox.size.height > 0) {
                glyphs.append(GlyphNode(glyph: glyph))
            }
            if Int(glyph) >= kCGGlyphMax {
                break
            }
        }
        didChange(.Insertion, valuesAtIndexes: NSIndexSet(indexesInRange: NSMakeRange(0, font.numberOfGlyphs)), forKey: "glyphs")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

