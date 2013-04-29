//
//  WSPreferencesController.h
//  WineBottler
//
//  Created by Mike Kronenberg on 17.04.09.
//  Copyright 2009 Kronenberg Informatik Lösungen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WSController.h"


@interface WSPreferencesController : NSObject <NSToolbarDelegate> {
	IBOutlet WSController *controller;
	IBOutlet NSWindow *preferencesWindow;
	
	IBOutlet NSView *preferencesViewGeneral;
	IBOutlet NSView *preferencesViewAdvanced;
	
	IBOutlet NSButton *logButton;
	IBOutlet NSButton *showWineWindowButton;
	
	NSUserDefaults *userDefaults;
}
- (void) showGeneral:(id)sender;
- (IBAction) showWineWindow:(id)sender;


- (void) showAdvanced:(id)sender;
- (IBAction) changeLogfile:(id)sender;
@end
