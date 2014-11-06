//
//  GlyphTableCell.m
//  FontInspector
//
//  Created by Litherum on 11/5/14.
//  Copyright (c) 2014 Litherum. All rights reserved.
//

#import "GlyphTableCell.h"

@implementation GlyphTableCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.layoutManager = [[NSLayoutManager alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        self.layoutManager = [[NSLayoutManager alloc] init];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    GlyphTableCell *ret = [super copyWithZone:zone];
    if (ret) {
        ret.layoutManager = [[NSLayoutManager alloc] init];
    }
    return ret;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    CGGlyph glyph = self.integerValue;
    NSPoint point = NSMakePoint(cellFrame.origin.x, cellFrame.origin.y + cellFrame.size.height + [self.font descender]);
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];
    [self.font setInContext:context];
    [self.layoutManager showCGGlyphs:&glyph positions:&point count:1 font:self.font matrix:[NSAffineTransform transform] attributes:@{} inContext:context];
    [context restoreGraphicsState];
}

@end