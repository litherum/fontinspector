//
//  AppDelegate.swift
//  FontInspector
//
//  Created by Litherum on 11/4/14.
//  Copyright (c) 2014 Litherum. All rights reserved.
//

import Cocoa

class CodepointNumberValueTransformer : NSValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSNumber.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        if let specificValue = value as? NSNumber {
            return specificValue
        }
        return nil
    }
}

class CodepointStringValueTransformer : NSValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        if let specificValue = value as? NSNumber {
            return String(UnicodeScalar(specificValue.integerValue))
        }
        return nil
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var codepointController: NSTreeController!

    var font: NSFont!
    var codepoints: [PlaneNode]

    override init() {
        font = NSFont(name: "American Typewriter", size: 12);
        codepoints = []
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSValueTransformer.setValueTransformer(CodepointNumberValueTransformer(), forName: "CodepointNumberValueTransformer")
        NSValueTransformer.setValueTransformer(CodepointStringValueTransformer(), forName: "CodepointStringValueTransformer")
        populate()
    }

    func populate() {
        if font == nil {
            return
        }

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
            codepointController.insertObject(PlaneNode(children: blocksInPlane, plane: plane), atArrangedObjectIndexPath: NSIndexPath(index: codepoints.count))
/*
            willChange(.Insertion, valuesAtIndexes: NSIndexSet(index: codepoints.count), forKey: "codepoints")
            codepoints.append(PlaneNode(children: blocksInPlane, plane: plane))
            didChange(.Insertion, valuesAtIndexes: NSIndexSet(index: codepoints.count), forKey: "codepoints")
*/
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

