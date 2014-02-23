/*
 * WPrefixTableView.h
 * of the 'WineStatus' target in the 'WineBottler' project
 *
 * Copyright 2007 Mike Kronenberg, inspired by transmission
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 */



#import "WPrefixTableView.h"
#import "WPrefixController.h"



#define ICON_X 3.0
#define ICON_Y 15.0
#define ICON_SPACE 3.0



@implementation WPrefixTableView
- (id) initWithCoder: (NSCoder *) decoder
{
	W_DEBUG(@"init");

    if ((self = [super initWithCoder: decoder]))
    {
        wDeleteIcon = [NSImage imageNamed: @"deleteIconTemplate.tiff"];
        wFinderIcon = [NSImage imageNamed: @"finderIconTemplate.tiff"];
        icon_width = [wDeleteIcon size].width;
        icon_height = [wDeleteIcon size].height;
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
			cellRect.origin.x + cellRect.size.width - (i + 1) * (icon_width + ICON_SPACE),
            cellRect.origin.y + ICON_Y,
            icon_width,
            icon_height
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
			cellRect.origin.x + cellRect.size.width - (i + 1) * (icon_width + ICON_SPACE),
            cellRect.origin.y + ICON_Y,
            icon_width,
            icon_height
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
        point = NSMakePoint(cellRect.origin.x + cellRect.size.width - 2 * (icon_width + ICON_SPACE), cellRect.origin.y + ICON_Y);
        if (NSPointInRect(pointClicked, NSMakeRect(point.x, point.y, icon_width, icon_height))) {
            wFraction = 1.0;
        } else {
			wFraction = 0.5;
		}
        [wDeleteIcon
            drawInRect: NSMakeRect(point.x, point.y, icon_width, icon_height)
            fromRect: NSMakeRect(0, 0, [wDeleteIcon size].width, [wDeleteIcon size].height)
            operation: NSCompositeSourceOver
            fraction: wFraction
        ];

        // finder icon
        point = NSMakePoint(cellRect.origin.x + cellRect.size.width - 1 * (icon_width + ICON_SPACE), cellRect.origin.y + ICON_Y);
        if (NSPointInRect(pointClicked, NSMakeRect(point.x, point.y, icon_width, icon_height))) {
            wFraction = 1.0;
		} else {
			wFraction = 0.5;
		}
        [wFinderIcon
            drawInRect: NSMakeRect(point.x, point.y, icon_width, icon_height)
            fromRect: NSMakeRect(0, 0, [wFinderIcon size].width, [wFinderIcon size].height)
            operation: NSCompositeSourceOver
            fraction: wFraction
        ];
	}
}
@end