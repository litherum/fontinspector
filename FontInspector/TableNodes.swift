//
//  CodepointNodes.swift
//  FontInspector
//
//  Created by Litherum on 11/5/14.
//  Copyright (c) 2014 Litherum. All rights reserved.
//

import Cocoa

class CodepointNode: NSObject {
    let codepoint: UnicodeScalar

    init(codepoint: UnicodeScalar) {
        self.codepoint = codepoint
    }

    func isLeaf() -> Bool {
        return true
    }

    func description() -> String {
        return String(format: "%d", codepoint.value)
    }

    func displayString() -> String {
        var result = ""
        result.append(codepoint)
        return result
    }

    func tableValue() -> String {
        return String(codepoint)
    }
}

class BlockNode: NSObject {
    let children: [CodepointNode]
    let blockCode: UBlockCode

    init(children: [CodepointNode], blockCode: UBlockCode) {
        self.children = children
        self.blockCode = blockCode
    }

    func isLeaf() -> Bool {
        return false
    }

    func description() -> String {
        return String(format: "Block %d", blockCode.value)
    }

    func tableValue() -> String {
        return ""
    }
}

class PlaneNode: NSObject {
    let children: [BlockNode]
    let plane: UInt8

    init(children: [BlockNode], plane: UInt8) {
        self.children = children
        self.plane = plane
    }

    func isLeaf() -> Bool {
        return false
    }

    func description() -> String {
        return String(format: "Plane %d", plane)
    }

    func tableValue() -> String {
        return ""
    }
}

class GlyphNode: NSObject {
    let glyph: NSGlyph

    init(glyph: NSGlyph) {
        self.glyph = glyph
    }
}

class GlyphDetailNode: GlyphNode {
    let font: NSFont
    let run: UInt
    var fontName : String {
        get {
            return font.displayName!
        }
    }

    init(glyph: NSGlyph, font: NSFont, run: UInt) {
        self.font = font
        self.run = run
        super.init(glyph: glyph)
    }
}