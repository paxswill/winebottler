/*
 * WPrefixTableView
 * 
 * Copyright (c) 2007 - 2009 Mike Kronenberg
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "WPrefixTableView.h"
#import "WPrefixController.h"


#define ICON_WIDTH 12.0
#define ICON_HEIGHT 12.0
#define ICON_X 3.0
#define ICON_Y 15.0
#define ICON_SPACE 3.0



@implementation WPrefixTableView
- (id) initWithCoder: (NSCoder *) decoder
{
	W_DEBUG(@"init");

    if ((self = [super initWithCoder: decoder]))
    {
        wDeleteIcon = [NSImage imageNamed: @"mDelete.png"];
        wFinderIcon = [NSImage imageNamed: @"mFinder.png"];
		[wFinderIcon setFlipped:YES];
    }
    
    return self;
}


- (void) mouseDown: (NSEvent *) event
{
	W_DEBUG(@"mouseDown");

    int i;
    BOOL clicked = false;
    pointClicked = [self convertPoint:[event locationInWindow] fromView:nil];
    int row = [self rowAtPoint: pointClicked];
    NSRect cellRect = [self frameOfCellAtColumn:2 row:row];
    
    for (i = 0; i < 2; i++) {
        if (NSPointInRect(pointClicked, NSMakeRect(
			cellRect.origin.x + cellRect.size.width - (i + 1) * (ICON_WIDTH + ICON_SPACE),
            cellRect.origin.y + ICON_Y,
            ICON_WIDTH,
            ICON_HEIGHT
        ))) {
            switch (i) {
                case 1: // delete
                    clicked = TRUE;
                break;
                case 0: // finder
                    clicked = TRUE;
                break;
            }
        }
    }
    
    if (clicked)
        [self display];
    else {
        pointClicked = NSZeroPoint;
		[super mouseDown: event];
    }
}


- (void) mouseUp: (NSEvent *) event
{
	W_DEBUG(@"mouseUp");

    int i;
	int row;
	NSRect cellRect;
    BOOL clicked;
	
	clicked = false;
    pointClicked = [self convertPoint:[event locationInWindow] fromView:nil];
    row = [self rowAtPoint: pointClicked];
    cellRect = [self frameOfCellAtColumn:2 row:row];
	
    for (i = 0; i < 2; i++) {
        if (NSPointInRect(pointClicked, NSMakeRect(
			cellRect.origin.x + cellRect.size.width - (i + 1) * (ICON_WIDTH + ICON_SPACE),
            cellRect.origin.y + ICON_Y,
            ICON_WIDTH,
            ICON_HEIGHT
        ))) {
            switch (i) {
					
                case 1: // delete
					[(WPrefixController *)[super delegate] deleteAtRow:row];
					break;
					
				case 0: // finder
					[(WPrefixController *)[super delegate] showInFinderAtRow:row];
					break;
            }
        }
    }

    pointClicked = NSZeroPoint;
    [self display];
    
    if (!clicked)
        [super mouseUp: event];
}


- (void) drawRect: (NSRect) rect
{
	W_DEBUG(@"drawRect");

    NSRect cellRect;
    NSPoint point;
    float wFraction;
    int i;
	
    [super drawRect: rect];

    for (i = 0; i < [super numberOfRows]; i++) {
        cellRect = [self frameOfCellAtColumn:2 row:i];
        
        // delete icon
        point = NSMakePoint(cellRect.origin.x + cellRect.size.width - 2 * (ICON_WIDTH + ICON_SPACE), cellRect.origin.y + ICON_Y);
        if (NSPointInRect(pointClicked, NSMakeRect(point.x, point.y, ICON_WIDTH, ICON_HEIGHT))) {
            wFraction = 1.0;
        } else {
			wFraction = 0.5;
		}
        [wDeleteIcon
            drawInRect: NSMakeRect(point.x, point.y, ICON_WIDTH, ICON_HEIGHT)
            fromRect: NSMakeRect(0, 0, [wDeleteIcon size].width, [wDeleteIcon size].height)
            operation: NSCompositeSourceOver
            fraction: wFraction
        ];

        // finder icon
        point = NSMakePoint(cellRect.origin.x + cellRect.size.width - 1 * (ICON_WIDTH + ICON_SPACE), cellRect.origin.y + ICON_Y);
        if (NSPointInRect(pointClicked, NSMakeRect(point.x, point.y, ICON_WIDTH, ICON_HEIGHT))) {
            wFraction = 1.0;
		} else {
			wFraction = 0.5;
		}
        [wFinderIcon
            drawInRect: NSMakeRect(point.x, point.y, ICON_WIDTH, ICON_HEIGHT)
            fromRect: NSMakeRect(0, 0, [wFinderIcon size].width, [wFinderIcon size].height)
            operation: NSCompositeSourceOver
            fraction: wFraction
        ];
	}
}
@end