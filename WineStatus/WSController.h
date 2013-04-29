//
//  WSController.h
//  WineBottler
//
//  Created by Mike Kronenberg on 31.03.09.
//  Copyright 2009 Kronenberg Informatik Lösungen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WBottler/WWinetricksController.h>


@interface WSController : NSObject {
	NSArray *arguments;
	NSUserDefaults *userDefaults;
	
	IBOutlet NSStatusItem *statusItem;
	IBOutlet NSMenu *statusItemMenu;
	IBOutlet NSMenu *menuProcesses;
	
	IBOutlet NSWindow *prefixesWindow;
	IBOutlet NSWindow *preferencesWindow;
	IBOutlet NSWindow *winetricksWindow;
	IBOutlet NSPanel *quitWindow;
	
	IBOutlet NSPanel *wineWindow;
	IBOutlet NSButton *wineWindowShow;
	IBOutlet NSPopUpButton *buttonPrefixes;
	IBOutlet NSButtonCell *buttonRunInPrefix;
	IBOutlet NSButtonCell *buttonRunExpressBottler;
	IBOutlet NSButtonCell *buttonRunOptionBottler;
	
	IBOutlet WWinetricksController *winetricksController;

	NSFileHandle *fileHandle;
	NSMutableArray *runningExes;
	
	NSMutableDictionary *tasks;
	
	BOOL appDidFinishLaunching;
	NSString *initialFilename;
}
- (void) toggleLogFile;

- (IBAction) wineWindowAbort:(id)sender;
- (IBAction) wineWindowGo:(id)sender;
- (void) startFile:(NSString *)filename;
- (IBAction) showWineWindow:(id)sender;

- (IBAction) startRegedit:(id)sender;
- (IBAction) startExplorer:(id)sender;
- (IBAction) startDos:(id)sender;
- (IBAction) shutDown:(id)sender;
- (IBAction) startConfig:(id)sender;
- (IBAction) startControl:(id)sender;
- (IBAction) showPrefixes:(id)sender;
- (IBAction) showPreferences:(id)sender;
- (IBAction) showWinetricks:(id)sender;
- (IBAction) kill:(id)sender;
- (IBAction) showLog:(id)sender;
- (IBAction) quitWindowQuit:(id)sender;
- (IBAction) quitWIndowCancle:(id)sender;

- (void) updateStatusItemMenu;
- (void) createPrefix;
- (void) changePrefixTo:(NSString *)tPrefix;
- (void) changePrefixAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void) killWine;
- (BOOL) startApplication:(NSArray *)tArguments;
- (void) updateStatusItemMenu;
- (void) checkATaskStatus:(NSNotification *)aNotification;

- (NSFileHandle *) fileHandle;
- (NSUserDefaults *) userDefaults;
@end
