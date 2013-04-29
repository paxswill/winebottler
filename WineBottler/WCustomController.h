//
//  WCustomController.h
//  WineBottler
//
//  Created by Mike Kronenberg on 04.10.09.
//  Copyright 2009 Kronenberg Informatik Lösungen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <WBottler/WBottler.h>
#import <WBottler/WWinetricksController.h>


@interface WCustomController : NSObject {
	id bottlerController;
	IBOutlet WWinetricksController* winetricksController;
	
	IBOutlet NSPopUpButton *prefixes;
	IBOutlet NSTextField *switches;
	IBOutlet NSTextField *executableArguments;
	IBOutlet NSTextField *bundleVersion;
	IBOutlet NSTextField *bundleIdentifier;
	IBOutlet NSTextField *overriedes;
	IBOutlet NSTextField *installer;
	IBOutlet NSMatrix *copyInstall;
	IBOutlet NSButton *silentInstall;
	IBOutlet NSButton *selfcontainedInstall;
}
- (IBAction) createCustom:(id)sender;
- (void) askForFilename;
- (IBAction) selectInstaller:(id)sender;
@end
