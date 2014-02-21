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



#import "WSController.h"
#import "WTask.h"
#import <WBottler/WBottler.h>
#import "WHLnk.h"
#include <sys/stat.h>



@implementation WSController
- (id) init
{
	self = [super init];
	if (self) {
		NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
		
		appDidFinishLaunching = NO;
		initialFilename = nil;
		
		//userdefauts
		[[NSUserDefaults standardUserDefaults] registerDefaults:
		 [NSDictionary dictionaryWithObjects:
		  [NSArray arrayWithObjects:
		   [NSString stringWithFormat:@"%@/Wine_bin.app/Contents/Resources", [[NSBundle mainBundle] resourcePath]],// winePath
		   [NSString stringWithFormat:@"%@/Wine Files", NSHomeDirectory()],		// prefix
		   @"",																	// arguments
		   [NSNumber numberWithBool:NO],										// doLog
		   [[[NSArray alloc] init] autorelease],								// knownPrefixes
		   [NSNumber numberWithBool:YES],										// showPrefixes
		   [NSNumber numberWithBool:YES],										// showPreferences
		   [NSNumber numberWithBool:YES],										// showWinetricks
		   [NSNumber numberWithBool:YES],										// showWineWindow
		   nil]
									   forKeys:
		  [NSArray arrayWithObjects:
		   @"winePath",
		   @"prefix",
		   @"arguments",
		   @"doLog",
		   @"knownPrefixes",
		   @"showPrefixes",
		   @"showPreferences",
		   @"showWinetricks",
		   @"showWineWindow",
		   nil]]];
        userDefaults = [NSUserDefaults standardUserDefaults];
		
		// force our wine package
		[userDefaults setObject:[[NSBundle mainBundle] resourcePath] forKey:@"winePath"];
		[userDefaults synchronize];
		
		runningExes = [[NSMutableArray alloc] initWithCapacity:16];
		tasks = [[NSMutableDictionary alloc] initWithCapacity:16]; // keep track of tasks
		
		// NSStatusItem
		statusItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
		[statusItem retain];
		[statusItem setHighlightMode:YES];
		[statusItem setImage:[NSImage imageNamed:@"WineStatusIcon.pdf"]];

		// Logfile
		[self toggleLogFile];
		
        // we want to be notified about termination of tasks
        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(checkATaskStatus:) 
													 name:NSTaskDidTerminateNotification
												   object:nil];
		
	}
	return self;
}


- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	// save defaults
    [userDefaults synchronize];
	
	[initialFilename release];
	[runningExes release];
	[tasks release];
	[statusItem release];
	if (fileHandle)
		[fileHandle release];
	[super dealloc];
}


- (void) toggleLogFile
{
	// Logfile
	int fd = -1;
	NSString *fullPath;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"doLog"]) {
		fullPath = [NSString stringWithFormat:@"%@/Library/Logs/Wine.log", NSHomeDirectory()];
		if ((fd = open((char *) [fullPath UTF8String], O_CREAT | O_WRONLY | O_APPEND | O_NONBLOCK, 0644)) != -1) {
			chmod ((char *) [fullPath UTF8String], S_IRUSR | S_IWUSR);
			fileHandle = [[NSFileHandle alloc] initWithFileDescriptor: fd closeOnDealloc: YES];
		} else {
			NSLog (@"Can\'t create file (%@) for StdErr redirection.", fullPath);
			fileHandle = [NSFileHandle fileHandleWithNullDevice];
		}
	} else {
		if (fileHandle)
			[fileHandle release];
		fileHandle = nil;
	}
}


- (void) updateStatusItemMenu
{
	NSUInteger loc;
	NSUInteger exeLoc;
	NSUInteger wineLoc;
	NSPipe *stdPipe;
	NSFileHandle *stdHandle;
	NSData *stdData = nil;
	NSTask *task;
	NSMutableData *data = nil;
	NSMutableString *string;
	NSString *line;
	NSString *taskPid;
	NSString *taskPath;
	NSDictionary *proc;
	int i;
	NSMenuItem *menuItem;
	NSString *path;
	NSRange range;
	
	// find all Wine tasks
	task = [[NSTask alloc] init];
	stdPipe = [NSPipe pipe];
	stdHandle = [stdPipe fileHandleForReading];
    [task setStandardOutput:stdPipe];
	data = [NSMutableData data];
    [task setLaunchPath:@"/bin/sh"];
	[task setArguments:[NSArray arrayWithObjects:@"-c", @"ps x | grep bin/wine", nil]];
	[task launch];
	while ((stdData = [stdHandle availableData]) && [stdData length]) {
		[data appendData:stdData];
    }
	[task release];

	// add tasks to runningExes
	[runningExes removeAllObjects];
	string = [[[NSMutableString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
	while ((loc = [string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r"]].location) != NSNotFound) {
		line = [string substringWithRange:NSMakeRange(0, loc + 1)];
		[string setString:[string substringFromIndex:loc + 1]];
		exeLoc = [line rangeOfString:@".exe"].location;
		wineLoc = [line rangeOfString:@"bin/wine"].location;
		if (exeLoc != NSNotFound) {
			taskPath = [line substringWithRange:NSMakeRange(wineLoc + 9, exeLoc + 4 - wineLoc - 9)];
			taskPid = [line substringToIndex:[[line substringFromIndex:3] rangeOfString:@" "].location + 3];
			proc = [NSDictionary dictionaryWithObjectsAndKeys:taskPid, @"pid", taskPath, @"path", nil];
			if (![runningExes containsObject:proc])
				[runningExes addObject:proc];
		}
	}

	// get current prefix
	range = [[userDefaults objectForKey:@"prefix"] rangeOfString:@".app"];
	if (range.location == NSNotFound) {
		path = [userDefaults objectForKey:@"prefix"];
	} else {
		path = [[userDefaults objectForKey:@"prefix"] substringToIndex:range.location + 4];
	}
	
	// set current prefix
	[[statusItemMenu itemAtIndex:4] setTitle:[NSString stringWithFormat:@"current prefix: %@",[path lastPathComponent]]];
	[[statusItemMenu itemAtIndex:4] setImage:[[NSWorkspace sharedWorkspace] iconForFile:path]];
	
	// remove old tasks
	while ([menuProcesses numberOfItems] > 0) {
		[menuProcesses removeItemAtIndex:0];
	}
	
	// add current tasks
	for (i = 0; i < [runningExes count]; i++) {
		menuItem = [[NSMenuItem alloc] initWithTitle:[[runningExes objectAtIndex:i] objectForKey:@"path"] action:@selector(kill:) keyEquivalent:@""];
		[menuItem setTag:[[[runningExes objectAtIndex:i] objectForKey:@"pid"] intValue]];
		[menuItem setImage:[NSImage imageNamed:@"kill.tiff"]];
		[menuProcesses insertItem:menuItem atIndex:i];
		[menuItem release];
	}
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	appDidFinishLaunching = YES;
}


- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{	
	// get rid of doublestarts at startup
	if (!appDidFinishLaunching && initialFilename != nil) {
		return false;
	}
	initialFilename = filename;
	[initialFilename retain];

	// what shall we do?
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showWineWindow"]) {
		
		[wineWindow makeKeyAndOrderFront:self];
		
		int i;
		NSArray *prefixes;
		prefixes = [[NSUserDefaults standardUserDefaults] objectForKey:@"knownPrefixes"];
		while ([[buttonPrefixes menu] numberOfItems] > 0) {
			[[buttonPrefixes menu] removeItemAtIndex:0];
		}
		if ([prefixes count] == 0) {
			[[buttonPrefixes menu] addItemWithTitle:[NSString stringWithFormat:@"%@/Wine Files", NSHomeDirectory()] action:nil keyEquivalent:@""];
		}
		for (i = 0; i < [prefixes count]; i++) {
			[[buttonPrefixes menu] addItemWithTitle:[prefixes objectAtIndex:i] action:nil keyEquivalent:@""];
		}
		
		// wineBottler installed?
		//	buttonRunInPrefix;
		if ([[NSWorkspace sharedWorkspace] fullPathForApplication:@"WineBottler.app"]) {
			[buttonRunExpressBottler setEnabled:YES];
			[buttonRunOptionBottler setEnabled:YES];
		} else {
			[buttonRunExpressBottler setEnabled:NO];
			[buttonRunOptionBottler setEnabled:NO];
		}
		[wineWindowShow setState:NSOffState];
		
		// what shall we do?
		[wineWindow makeKeyAndOrderFront:self];
		[preferencesWindow setLevel:NSFloatingWindowLevel];
	
	} else {
		[self startFile:initialFilename];
	}

	return TRUE;
}


- (IBAction) wineWindowAbort:(id)sender
{
	[wineWindow orderOut:self];
}


- (IBAction) wineWindowGo:(id)sender
{
	[wineWindow orderOut:self];
	if ([buttonRunInPrefix state] == NSOnState) {
		[[NSUserDefaults standardUserDefaults] setObject:[buttonPrefixes titleOfSelectedItem] forKey:@"prefix"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self startFile:initialFilename];
	} else if ([buttonRunExpressBottler state] == NSOnState) {
		[[NSWorkspace sharedWorkspace] openFile:initialFilename withApplication:@"WineBottler.app"];
	}
}


- (IBAction) showWineWindow:(id)sender
{
	if ([sender state] == NSOnState) {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"showWineWindow"];
	} else {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showWineWindow"];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];
}


- (void) startFile:(NSString *)filename
{
	// start file
	if ([[filename pathExtension] caseInsensitiveCompare:@"msi"] == NSOrderedSame) {
		[self startApplication:[NSArray arrayWithObjects:@"msiexec.exe", @"/i", filename, nil]];
	} else if ([[filename pathExtension] caseInsensitiveCompare:@"bat"] == NSOrderedSame) {
		[self startApplication:[NSArray arrayWithObjects:@"cmd.exe", @"/c", [NSString stringWithFormat:@"start /Unix %@", filename], nil]];
	} else if ([[filename pathExtension] caseInsensitiveCompare:@"lnk"] == NSOrderedSame) {
		WHLnk *lnk = [[[WHLnk alloc] initWithLnk:filename] autorelease];
		if ([lnk flags] & SCF_LOCATION) {
			if ([lnk flags] & SCF_ARGS) {
				NSMutableArray *array = [NSMutableArray arrayWithArray:[lnk arguments]];
				[array insertObject:[lnk localPath] atIndex:0];
				[self startApplication:array];
			} else {
				[self startApplication:[NSArray arrayWithObject:[lnk localPath]]];
			}
		}
	} else if ([[filename pathExtension] caseInsensitiveCompare:@"exe"] == NSOrderedSame) {
		[self startApplication:[NSArray arrayWithObject:filename]];
	}
}


- (void) awakeFromNib
{
	[statusItem setMenu:statusItemMenu];
	[self updateStatusItemMenu];
	if ([userDefaults boolForKey:@"showPrefixes"])
		[self showPrefixes:self];
	if ([userDefaults boolForKey:@"showPreferences"])
		[self showPreferences:self];
	if ([userDefaults boolForKey:@"showWinetricks"])
		[self showWinetricks:self];
	
	// start timer to update tasks in statusbar
	[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(updateStatusItemMenu) userInfo:nil repeats:YES];
}



#pragma mark -
#pragma mark prefix
- (void) createPrefix
{
	[[[WBottler alloc] initWithScript:@"customprefix.sh"
                                  URL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"prefix"]]
							 template:nil
						 installerURL:nil
					installerIsZipped:nil
						installerName:nil
				   installerArguments:nil
						   winetricks:nil
							overrides:nil
								  exe:@"notneeded"
						 exeArguments:nil
						bundleVersion:nil
					 bundleIdentifier:nil
                      bundleSignature:nil
							   silent:nil
						selfcontained:NO
							   sender:self
							 callback:@selector(createPrefixCallback:)] autorelease];
}


- (void) createPrefixCallback:(BOOL)tSuccess
{
	WTask *task;
	if (tSuccess) {
		// now that we have a prefix, run the app
		task = [[WTask alloc] initWithArguments:arguments controller:self];
		[tasks setObject:task forKey:[NSNumber numberWithInt:[[task task] processIdentifier]]];
		[task release];
		[arguments release];
		[self updateStatusItemMenu];
	} else {
		// need some error handling here
	}
}


- (void) changePrefixTo:(NSString *)tPrefix
{
	 NSAlert *alert;
	 
	 alert = [[NSAlert alloc] init];
	 [alert setMessageText:@"You are about to change the prefix."];
	 [alert setInformativeText:[NSString stringWithFormat:@"Are you sure you want to change the prefix to %@?", tPrefix]];
	 [alert setAlertStyle:NSWarningAlertStyle];
	 [alert addButtonWithTitle:@"OK"];
	 [alert addButtonWithTitle:@"Cancel"];
	 [alert beginSheetModalForWindow:prefixesWindow
					   modalDelegate:self
					  didEndSelector:@selector(changePrefixAlertDidEnd:returnCode:contextInfo:)
						 contextInfo:tPrefix];
}


- (void) changePrefixAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	switch (returnCode) {
		case NSAlertFirstButtonReturn:
			[[NSUserDefaults standardUserDefaults] setObject:contextInfo forKey:@"prefix"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			break;
		case NSAlertSecondButtonReturn:
			break;
	}
	[[alert window] orderOut:self];
}



#pragma mark -
#pragma mark Quit
- (void) killWine
{
	NSTask *task;
	task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
	[task setArguments:[NSArray arrayWithObject:[NSString stringWithFormat:@"%@/killwine.sh", [[NSBundle mainBundle] resourcePath]]]];
	[task launch];
	[task waitUntilExit];
	[task release];
}


- (IBAction) shutDown:(id)sender
{
	// NSAlert would work, but windowlevel ist to low, so it gets lost on crowded screens
	[quitWindow makeKeyAndOrderFront:self];
	[quitWindow setLevel:NSScreenSaverWindowLevel - 1];
}


- (IBAction) quitWindowQuit:(id)sender
{
	[self killWine]; // remove all running wine processes
	[NSApp terminate:self];
}


- (IBAction) quitWIndowCancle:(id)sender
{
	[quitWindow orderOut:self];
}



#pragma mark -
#pragma mark handle exe
- (BOOL) startApplication:(NSArray *)tArguments
{
	WTask *task;
	arguments = tArguments;
	[arguments retain];

	// check if prefix exists, else run initializer script
	if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/system.reg", [[NSUserDefaults standardUserDefaults] objectForKey:@"prefix"]]]) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@/Wine Files", NSHomeDirectory()] forKey:@"prefix"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self createPrefix];
	
	// directly run app
	} else {
		task = [[WTask alloc] initWithArguments:arguments controller:self];
		[tasks setObject:task forKey:[NSNumber numberWithInt:[[task task] processIdentifier]]];
		[task release];
		[self updateStatusItemMenu];
		[arguments release];
	}
	
	return YES;
}


- (void) checkATaskStatus:(NSNotification *)aNotification
{
	if ([tasks objectForKey:[NSNumber numberWithInt:[[aNotification object] processIdentifier]]]) {
		[tasks removeObjectForKey:[NSNumber numberWithInt:[[aNotification object] processIdentifier]]];
		[self updateStatusItemMenu];
	}
}



#pragma mark -
#pragma mark menuItems
- (IBAction) startRegedit:(id)sender
{
	[self startApplication:[NSArray arrayWithObject:@"regedit"]];
}


- (IBAction) startExplorer:(id)sender
{
	[self startApplication:[NSArray arrayWithObject:@"winefile"]];
}


- (IBAction) startDos:(id)sender
{
	[self startApplication:[NSArray arrayWithObjects:@"wineconsole", @"cmd", nil]];
}


- (IBAction) startConfig:(id)sender
{
	[self startApplication:[NSArray arrayWithObject:@"winecfg"]];
}


- (IBAction) startControl:(id)sender
{
	[self startApplication:[NSArray arrayWithObject:@"control"]];
}


- (IBAction) kill:(id)sender
{
	NSTask *task;
	
	task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/kill"];
	[task setArguments:[NSArray arrayWithObjects:@"-9", [NSString stringWithFormat:@"%ld", (long)[sender tag]], nil]];
	[task launch];
	[task waitUntilExit];
	[task release];
	[self updateStatusItemMenu];
}


- (IBAction) showLog:(id)sender
{
	[[NSWorkspace sharedWorkspace] openFile:[@"~/Library/Logs/Wine.log" stringByExpandingTildeInPath] withApplication:@"Console"];
}



#pragma mark -
#pragma mark windows and windows delegate
- (IBAction) showPrefixes:(id)sender
{
	[prefixesWindow makeKeyAndOrderFront:self];
	[prefixesWindow setLevel:NSFloatingWindowLevel];
	[userDefaults setBool:YES forKey:@"showPrefixes"];
	[userDefaults synchronize];
}


- (IBAction) showPreferences:(id)sender
{
	[preferencesWindow makeKeyAndOrderFront:self];
	[preferencesWindow setLevel:NSFloatingWindowLevel];
	[userDefaults setBool:YES forKey:@"showPreferences"];
	[userDefaults synchronize];
}


- (IBAction) showWinetricks:(id)sender
{
	[winetricksWindow makeKeyAndOrderFront:self];
	[winetricksWindow setLevel:NSFloatingWindowLevel];
	[userDefaults setBool:YES forKey:@"showWinetricks"];
	[userDefaults synchronize];
	
	[winetricksController update:self];
}


- (BOOL) windowShouldClose:(id)window
{
	if ([window isEqual:prefixesWindow]) {
		[userDefaults setBool:NO forKey:@"showPrefixes"];
	} else if ([window isEqual:preferencesWindow]) {
		[userDefaults setBool:NO forKey:@"showPreferences"];
	} else if ([window isEqual:winetricksWindow]) {
		[userDefaults setBool:NO forKey:@"showWinetricks"];
	}
	[userDefaults synchronize];
	
	return  YES;
}



#pragma mark -
#pragma mark getters & setters
- (NSFileHandle *) fileHandle {return fileHandle;}
- (NSUserDefaults *) userDefaults {return userDefaults;}
@end
