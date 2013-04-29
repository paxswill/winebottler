//
//  WBController.h
//  WineBottler
//
//  Created by Mike Kronenberg on 31.03.09.
//  Copyright 2009 Kronenberg Informatik Lösungen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <WBottler/WBottler.h>
#import <WBottler/WWinetricksController.h>
#import "WBottlerController.h"



@interface WBController : NSObject {
	NSArray *arguments;
	NSUserDefaults *userDefaults;
	
	IBOutlet NSWindow *bottlerWindow;
	IBOutlet NSWindow *preferencesWindow;
	
	IBOutlet id wineBottlerController;
	IBOutlet NSTextField *installer;
	IBOutlet WWinetricksController *winetricksController;
	
	
}
- (IBAction) showBottler:(id)sender;
- (IBAction) showPreferences:(id)sender;
- (NSUserDefaults *) userDefaults;
@end
