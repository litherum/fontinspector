//
//  AppDelegate.swift
//  FontInspector
//
//  Created by Litherum on 11/4/14.
//  Copyright (c) 2014 Litherum. All rights reserved.
//

import Cocoa

class CodepointsValueTransformer : NSValueTransformer {
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
    override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        return nil
    }
}

class CodepointNode: NSObject {
    var isLeaf: Bool
    var children: [CodepointNode]
    var codepoint: UnicodeScalar

    init(isLeaf: Bool, children: [CodepointNode], codepoint: UnicodeScalar) {
        self.isLeaf = isLeaf
        self.children = children
        self.codepoint = codepoint
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var codepointController: NSTreeController!

    var codepoints: NSArray

    override init() {
        codepoints = []
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSValueTransformer.setValueTransformer(CodepointsValueTransformer(), forName: "CodepointsValueTransformer")

        let object1 = CodepointNode(isLeaf: false, children: [], codepoint: UnicodeScalar(68))
        let object2 = CodepointNode(isLeaf: true, children: [], codepoint: UnicodeScalar(111))
        let keypath1 = NSIndexPath(index: 0);
        let keypath2 = keypath1.indexPathByAddingIndex(0);
        codepointController.insertObject(object1, atArrangedObjectIndexPath: keypath1)
        codepointController.insertObject(object2, atArrangedObjectIndexPath: keypath2)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

