/*
 * WTController.m
 * of the 'Winetricks' target in the 'WineBottler' project
 *
 * Copyright 2010 Mike Kronenberg
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



#import "WTController.h"



@implementation WTController
- (void) awakeFromNib {
	NSArray *args;
		
	args = [[NSProcessInfo processInfo] arguments];
	if ([args count] > 1) {
		[self copyPrefixFromPath:[args objectAtIndex:1] toPath:[args objectAtIndex:2] withTitle:[args objectAtIndex:3]];
	} else {
		[winetricksWindow setDelegate:self];
		[winetricksController update:self];
		[winetricksWindow orderFront:self];
	}
}


- (void) windowWillClose:(NSNotification *)notification {
	[NSApp terminate:self];
}


- (void) copyPrefixFromPath:(NSString *)fromPath toPath:(NSString *)toPath withTitle:(NSString *)tTitle {
	NSArray *subPaths;
	int i;

	[[KBActionWindow sharedKBActionWindow] setTitle:[NSString stringWithFormat:@"Starting %@", tTitle]];
	[[[KBActionWindow sharedKBActionWindow] window] setLevel:NSScreenSaverWindowLevel - 1];
	
	copyAction = [[KBActionWindow sharedKBActionWindow]
				  addActionWithTitle:[NSString stringWithFormat:@"Preparing \"%@\"", tTitle]
				  withDescription:@"Copying prefix..."
				  withIcon:[[[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Icon.icns", [fromPath stringByDeletingLastPathComponent]]] autorelease]
				  withAbortSelector:@selector(abort:)
				  forTarget:self];
	[copyAction setProgress:0.0];
	if (![[NSFileManager defaultManager] fileExistsAtPath:toPath]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:toPath withIntermediateDirectories:YES attributes:nil error:nil];  //createDirectoryAtURL:[NSURL fileURLWithPath:toPath] withIntermediateDirectories:YES attributes:nil error:nil];
		filesToCopy = [[[NSFileManager defaultManager] subpathsAtPath:fromPath] count];
		filesCopied = 0;
		subPaths = [NSArray arrayWithObjects:
					@"dosdevices",
					@"drive_c",
					@"system.reg",
					@"user.reg",
					@"userdef.reg",
					@"WineBottler.id",
					nil];
		[copyAction setProgress:1.0];
		[copyAction setDescription:[NSString stringWithFormat:@"Copying \"%@\" prefix", tTitle]];
		
		for (i = 0; i < [subPaths count]; i++) {
            if (![[NSFileManager defaultManager]
                  copyItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", fromPath, [subPaths objectAtIndex:i]]]
                  toURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", toPath, [subPaths objectAtIndex:i]]]
                  error:nil]) {
				NSLog(@"Can't copy from %@/%@ to %@", fromPath, [subPaths objectAtIndex:i], toPath);
			}
		}
	}
	[copyAction setProgress:100.0];
	[copyAction setDescription:[NSString stringWithFormat:@"Launching \"%@\"", tTitle]];
		
	[NSApp terminate:self];
}


- (IBAction) abort:(id)sender {	
	[NSApp terminate:self];
}



#pragma mark -
#pragma mark NSFileManager delegates
- (void) fileManager:(NSFileManager *)manager willProcessPath:(NSString *)path {
	[copyAction setProgress:(100.0 / filesToCopy * filesCopied)];
	[copyAction setDescription:[NSString stringWithFormat:@"Copying %@", [path lastPathComponent]]];
	filesCopied++;
}


- (BOOL) fileManager:(NSFileManager *)manager shouldProceedAfterError:(NSDictionary *)errorInfo {
	NSLog(@"Error %@", errorInfo);
	return NO;
}
@end
