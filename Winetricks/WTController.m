//
//  WTController.m
//  Winetricks
//
//  Created by Mike Kronenberg on 26.05.10.
//  Copyright 2010 Kronenberg Informatik Lösungen. All rights reserved.
//

#import "WTController.h"


@implementation WTController
- (void) awakeFromNib {
	NSArray *args;
//	float c[4];
//	NSMutableString *colorScheme;
		
	args = [[NSProcessInfo processInfo] arguments];
	if ([args count] > 1) {
/*
		colorScheme = [NSMutableString stringWithString:@"REGEDIT4\n\n[HKEY_CURRENT_USER\\Control Panel\\Colors]"];
		
//		[[[NSColor colorForControlTint:[NSColor currentControlTint]] colorUsingColorSpaceName:NSDeviceRGBColorSpace] getRed:&c[0] green:&c[1] blue:&c[2] alpha:&c[3]];
//		[colorScheme appendFormat:@"\n\"MenuHilight\"=\"%d %d %d\"", (int)(255 * c[0]), (int)(255 * c[1]), (int)(255 * c[2])]; // Returns the system color used for the background of large controls.
		
		[[[NSColor selectedTextColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace] getRed:&c[0] green:&c[1] blue:&c[2] alpha:&c[3]];
		[colorScheme appendFormat:@"\n\"HilightText\"=\"%d %d %d\"", (int)(255 * c[0]), (int)(255 * c[1]), (int)(255 * c[2])];	// Returns the system color used for the background of selected text.
		
		[[[NSColor selectedTextBackgroundColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace] getRed:&c[0] green:&c[1] blue:&c[2] alpha:&c[3]];
		[colorScheme appendFormat:@"\n\"Hilight\"=\"%d %d %d\"", (int)(255 * c[0]), (int)(255 * c[1]), (int)(255 * c[2])];	// Returns the system color used for the background of selected text.
				
		NSLog(@"%@", colorScheme);
*/		
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
		//[[NSFileManager defaultManager] createDirectoryAtURL:[NSURL fileURLWithPath:toPath] withIntermediateDirectories:YES attributes:nil error:nil];
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
