//
//  T5PaperView.m
//  Minirap
//
//  Created by Mike Kronenberg on 10.05.12.
//  Copyright (c) 2012 Tapenta GmbH. All rights reserved.
//

#import "T5PaperView.h"

@implementation T5PaperView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}



- (void) dealloc
{
    if (paper)
        [paper release];
    [super dealloc];
}

-(void) awakeFromNib {
    paper = [[NSImage imageNamed:@"paper"] retain];
}



- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor colorWithPatternImage:paper] setFill];
    NSRectFill(dirtyRect);
}
@end
