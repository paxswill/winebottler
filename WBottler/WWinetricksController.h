//
//  WWinetricksController.h
//  WineBottler
//
//  Created by Mike Kronenberg on 20.05.09.
//  Copyright 2009 Kronenberg Informatik Lösungen. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WWinetricksController : NSObject {
	NSMutableArray *tricks;
	NSArray *foundTricks;
	IBOutlet NSTextField *searchField;
	IBOutlet NSTableView *table;
	IBOutlet NSButton *silentInstall;
}
- (IBAction) search:(id)sender;
- (IBAction) update:(id)sender;
- (IBAction) apply:(id)sender;
- (IBAction) toggle:(id)sender;
- (IBAction) loadWinetricks:(id)sender;
- (NSString *) winetricks;
@end
