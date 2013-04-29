/*
 * WController.h
 * of the 'WineStatus' target in the 'WineBottler' project
 *
 * Copyright 2009 Mike Kronenberg
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
