//
//  WTask.m
//  WineBottler
//
//  Created by Mike Kronenberg on 01.04.09.
//  Copyright 2009 Kronenberg Informatik Lösungen. All rights reserved.
//

#import "WTask.h"



@implementation WTask
- (id) init
{
	self = [super init];
	if (self) {

		task = [[NSTask alloc] init];
		stdPipe = [NSPipe pipe];
		errPipe = [NSPipe pipe];
		stdHandle = [stdPipe fileHandleForReading];
		errHandle = [errPipe fileHandleForReading];
		stdData = [NSMutableData data];
		errData = [NSMutableData data];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(readFromStdPipe:) 
													 name:NSFileHandleReadCompletionNotification
												   object:stdHandle];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(readFromErrPipe:) 
													 name:NSFileHandleReadCompletionNotification
												   object:errHandle];
	}
	return self;
}


- (id)initWithArguments:(NSArray *)arguments controller:(id)tController
{
//	NSString *display;
	NSString *wineDebug;
	
	self = [self init];
	if (self) {
		//Controller
		controller = tController;

		// EXE
		exe = [[arguments objectAtIndex:0] lastPathComponent];
		
		// Pipes
		[task setStandardOutput:stdPipe];
		[task setStandardError:errPipe];
/*
		// Fix for Tiger environment bug
		display = [[[NSProcessInfo processInfo] environment] objectForKey:@"DISPLAY"];
		if (display == nil) {
			display = @":0.0";
			[[NSWorkspace sharedWorkspace] launchApplication:@"X11"];
		}
*/		
		// supress err & fixme messages if there is no log file
		if ([controller fileHandle]) {
			wineDebug = @"err+all,fixme+all";
		} else {
			wineDebug = @"err-all,fixme-all";
		}

		// Environment
		[task setEnvironment:[NSDictionary dictionaryWithObjects:
							  [NSArray arrayWithObjects:
							   [NSString stringWithFormat:@"%@/bin", [[NSUserDefaults standardUserDefaults] objectForKey:@"winePath"]],						// WINEPATH
//							   [NSString stringWithFormat:@"/usr/lib:%@/lib:/usr/X11R6/lib", [[NSUserDefaults standardUserDefaults] objectForKey:@"winePath"]],		// DYLD_FALLBACK_LIBRARY_PATH
//							   [NSString stringWithFormat:@"%@/lib:/usr/X11R6/lib", [[NSUserDefaults standardUserDefaults] objectForKey:@"winePath"]],		// LD_LIBRARY_PATH
							   [NSString stringWithFormat:@"/usr/lib:%@/lib", [[NSUserDefaults standardUserDefaults] objectForKey:@"winePath"]],		// DYLD_FALLBACK_LIBRARY_PATH
							   [NSString stringWithFormat:@"%@/lib", [[NSUserDefaults standardUserDefaults] objectForKey:@"winePath"]],		// LD_LIBRARY_PATH
							   [NSString stringWithFormat:@"%@/etc/fonts/fonts.conf", [[NSUserDefaults standardUserDefaults] objectForKey:@"winePath"]],	// FONTCONFIG_FILE
//							   [NSString stringWithFormat:@"%@/ssl/openssl.cnf", [[NSUserDefaults standardUserDefaults] objectForKey:@"winePath"]], // OPENSSL_CONF
							   [[NSUserDefaults standardUserDefaults] objectForKey:@"prefix"],					// WINEPREFIX
							   wineDebug,																		// WINEDEBUG
//							   display,																			// DISPLAY
							   NSUserName(),																	// USER
							   NSHomeDirectory(),																// HOME
							   nil]
														   forKeys:
							  [NSArray arrayWithObjects:
							   @"WINEPATH",
							   @"DYLD_FALLBACK_LIBRARY_PATH",
							   @"LD_LIBRARY_PATH",
							   @"FONTCONFIG_FILE",
//							   @"OPENSSL_CONF",
							   @"WINEPREFIX",
							   @"WINEDEBUG",
//							   @"DISPLAY",
							   @"USER",
							   @"HOME",
							   nil]]];
		
		// Wine
		NSLog(@"%@", [arguments objectAtIndex:0]);
		// switch to directory of app else switch to home directory
		if ([[[arguments objectAtIndex:0] substringToIndex:2] isEqual:@"C:"]) {
			[task setCurrentDirectoryPath:[NSString stringWithFormat:@"%@/dosdevices/c:/%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"prefix"], [[[self pathWithWindowsPath:[arguments objectAtIndex:0]] stringByDeletingLastPathComponent] substringFromIndex:3]]];
		} else if ([[[arguments objectAtIndex:0] stringByDeletingLastPathComponent] isEqual:@""]) {
			[task setCurrentDirectoryPath:[NSString stringWithFormat:@"%@/dosdevices/c:/", [[NSUserDefaults standardUserDefaults] objectForKey:@"prefix"]]];
		} else {
			[task setCurrentDirectoryPath:[[arguments objectAtIndex:0] stringByDeletingLastPathComponent]];
		}
		
		// start from wine bin
		[task setLaunchPath:[NSString stringWithFormat:@"%@/bin/wine", [[NSUserDefaults standardUserDefaults] objectForKey:@"winePath"]]];

		// Arguments
		[task setArguments:arguments];
		
		// go!
		[task launch];
		
		// observe
		[stdHandle readInBackgroundAndNotify];
		[errHandle readInBackgroundAndNotify];
	}
	return self;
}


- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	if (task) {
		if ([task isRunning])
			[task terminate];
		[task release];
	}
	
	[super dealloc];
}


- (void) readFromStdPipe:(NSNotification *)notification
{
//	NSLog(@"Std:%s", [[[notification userInfo] objectForKey:NSFileHandleNotificationDataItem] bytes]);
	if([task isRunning]) {
		if ([controller fileHandle])
			[[controller fileHandle] writeData:[[notification userInfo] objectForKey:NSFileHandleNotificationDataItem]];
        [[notification object] readInBackgroundAndNotify];
    }
}


- (void) readFromErrPipe:(NSNotification *)notification
{
//	NSLog(@"%s", [[[notification userInfo] objectForKey:NSFileHandleNotificationDataItem] bytes]);
	if([task isRunning]) {
		if ([controller fileHandle])
			[[controller fileHandle] writeData:[[notification userInfo] objectForKey:NSFileHandleNotificationDataItem]];
        [[notification object] readInBackgroundAndNotify];
    }
}


- (NSMutableString *) pathWithWindowsPath:(NSString *)path
{
	NSMutableString *tPath;
	
	tPath = [[path mutableCopy] autorelease];;
	[tPath replaceOccurrencesOfString:@"\\" withString:@"/" options:NSLiteralSearch range:NSMakeRange(0, [tPath length])];
	
	return tPath;
}



#pragma mark -
#pragma mark getters & setters
- (NSString *)exe {return exe;}
- (NSTask *)task {return task;}
@end
