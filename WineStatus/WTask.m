/*
 * WTask.h
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

		// supress err & fixme messages if there is no log file
		if ([controller fileHandle]) {
			wineDebug = @"err+all,fixme+all";
		} else {
			wineDebug = @"err-all,fixme-all";
		}

		// Environment
		[task setEnvironment:[NSDictionary dictionaryWithObjects:
							  [NSArray arrayWithObjects:
                               [NSString stringWithFormat:@"%@/bin:%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"winePath"], [[[NSProcessInfo processInfo] environment] objectForKey:@"PATH"]],
							   [NSString stringWithFormat:@"%@/bin", [[NSUserDefaults standardUserDefaults] objectForKey:@"winePath"]],						// WINEPATH
							   [NSString stringWithFormat:@"%@/lib:/usr/lib", [[NSUserDefaults standardUserDefaults] objectForKey:@"winePath"]],		// DYLD_FALLBACK_LIBRARY_PATH
							   [NSString stringWithFormat:@"%@/lib", [[NSUserDefaults standardUserDefaults] objectForKey:@"winePath"]],		// LD_LIBRARY_PATH
							   [NSString stringWithFormat:@"%@/etc/fonts/fonts.conf", [[NSUserDefaults standardUserDefaults] objectForKey:@"winePath"]],	// FONTCONFIG_FILE
							   [[NSUserDefaults standardUserDefaults] objectForKey:@"prefix"],					// WINEPREFIX
							   wineDebug,																		// WINEDEBUG
							   NSUserName(),																	// USER
							   NSHomeDirectory(),																// HOME
							   nil]
														   forKeys:
							  [NSArray arrayWithObjects:
                               @"PATH",
							   @"WINEPATH",
							   @"DYLD_FALLBACK_LIBRARY_PATH",
							   @"LD_LIBRARY_PATH",
							   @"FONTCONFIG_FILE",
							   @"WINEPREFIX",
							   @"WINEDEBUG",
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
