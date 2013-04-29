//
//  WBottler.h
//  WineBottler
//
//  Created by Mike Kronenberg on 26.04.09.
//  Copyright 2009 Kronenberg Informatik Lösungen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <KBActionWindow/KBActionWindow.h>
#import <KBActionWindow/KBAction.h>


typedef unsigned BottlerRunMode;
enum {
	BottlerRunModeApp = 0,
	BottlerRunModeWinetricks = 1,
	BottlerRunModePrefix = 2
};


typedef unsigned BottlerExitMode;
enum {
	BottlerExitModeNormal = 0,
	BottlerExitModeAbort = 1,
	BottlerExitModeError = 2
};

@interface WBottler : NSObject {
	BOOL finished;
	id bottlerController;
	SEL callback;
	
	IBOutlet NSPanel *findExePanel;
	IBOutlet NSPopUpButton *exeSelector;
	
	BottlerRunMode runMode;
	BottlerExitMode exitMode;
	
	NSPipe *stdPipe;
	NSPipe *errPipe;
	NSFileHandle *stdHandle;
	NSFileHandle *errHandle;
	NSTask *task;
	KBAction *installAction;
	double percent;
	NSURL *filename;
	NSString *pathtoExecutable;
	
	NSMutableString *stringBuffer;
	NSMutableString *log;
}
- (void) findWine;
- (id) initWithScript:(NSString *)tScript
			 URL:(NSURL *)tFilename
			 template:(NSString *)tTemplate
		 installerURL:(NSString *)tInstallerURL
	installerIsZipped:(NSString *)tInstallerIsZipped
		installerName:(NSString *)tInstallerName
   installerArguments:(NSString *)tInstallerArguments
		   winetricks:(NSString *)tWinetricks
			overrides:(NSString *)tOverrides
				  exe:(NSString *)tExe
		 exeArguments:(NSString *)tExeArguments
		bundleVersion:(NSString *)tBundleVersion
	 bundleIdentifier:(NSString *)tBundleIdentifier
			   silent:(NSString *)tSilent
		selfcontained:(BOOL)tSelfcontained
			   sender:(id)tSender
			 callback:(SEL)tSelector;
- (IBAction) abort:(id)sender;
- (IBAction) findExe:(id)sender;
- (IBAction) foundExe:(id)sender;
- (IBAction) finish:(id)sender;
- (void) callCallback:(BOOL)success;
- (void) checkATaskStatus:(NSNotification *)aNotification;
@end
