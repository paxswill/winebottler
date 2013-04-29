//
//  WPrefixController.h
//  WineBottler
//
//  Created by Mike Kronenberg on 17.04.09.
//  Copyright 2009 Kronenberg Informatik Lösungen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WSController.h"
#import "WBController.h"


@interface WPrefixController : NSObject <NSMetadataQueryDelegate> {
	IBOutlet id controller;
	id bottlerController;
	
	IBOutlet NSWindow *prefixesWindow;
	IBOutlet NSProgressIndicator *queryProgressIndicator;
	IBOutlet NSTextField *queryProgressText;
	IBOutlet NSTableView *table;
	IBOutlet NSButton *buttonNew;
	IBOutlet NSButton *buttonReload;
	IBOutlet NSTextField *searchField;
	
	NSMetadataQuery *query;
	NSArray *foundPrefixes;
}
- (void) setRow;
- (IBAction) queryForPrefixes:(id)sender;
- (IBAction) changePrefix:(id)sender;
- (IBAction) search:(id)sender;
- (IBAction) createNewPrefix:(id)sender;
- (void) deleteAtRow:(int)row;
- (void) deletePrefixAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void) showInFinderAtRow:(int)row;
@end
