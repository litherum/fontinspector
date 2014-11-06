//
//  GlyphTableCell.h
//  FontInspector
//
//  Created by Litherum on 11/5/14.
//  Copyright (c) 2014 Litherum. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GlyphTableCell : NSTextFieldCell
- (instancetype)init;
- (id)initWithCoder:(NSCoder *)decoder;
- (id)copyWithZone:(NSZone *)zone;
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@property NSLayoutManager *layoutManager;
@end
