/*
 * WBottler.m
 * of the 'WBottler' target in the 'WineBottler' project
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



#import "WBottler.h"



@implementation WBottler
- (id) init
{
	self = [super init];
	if (self) {
		
		// Take ownerschip
		[self retain];
		
		[self findWine];
		
		// Action Window
		[[KBActionWindow sharedKBActionWindow] setTitle:@"Install"];
		[[[KBActionWindow sharedKBActionWindow] window] setLevel:NSFloatingWindowLevel];
		
		percent = 0.0;
		stringBuffer = [[NSMutableString alloc] init];
		log = [[NSMutableString alloc] initWithCapacity:1024];
		
		exitMode = BottlerExitModeAbort;
		
		stdPipe = [NSPipe pipe];
		errPipe = [NSPipe pipe];
		stdHandle = [stdPipe fileHandleForReading];
		errHandle = [errPipe fileHandleForReading];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(readFromStdPipe:) 
													 name:NSFileHandleReadCompletionNotification
												   object:stdHandle];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(readFromErrPipe:) 
													 name:NSFileHandleReadCompletionNotification
												   object:errHandle];
		
        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(checkATaskStatus:) 
													 name:NSTaskDidTerminateNotification
												   object:nil];

	}
	return self;
}


- (void) findWine
{
	int i;
	NSArray *winePaths;
	NSFileManager *fileManager;
	NSAlert *alert;
	NSString *tWinePath;
	
	winePaths = [NSArray arrayWithObjects:
				 // in WineBottler
				 [NSString stringWithFormat:@"%@/Wine.bundle/Contents/Resources", [[NSBundle mainBundle] resourcePath]],
				
				 // in selfcontained App
				 [NSString stringWithFormat:@"%@../../../Wine.bundle/Contents/Resources", [[NSBundle mainBundle] resourcePath]],
                 
                 // find over NSWorkspace
				 [NSString stringWithFormat:@"%@/Contents/Resources", [[NSWorkspace sharedWorkspace] fullPathForApplication:@"Wine.app"]],
				 
				 // hardcoded
				 [@"~/Applications/Wine/Wine.bundle/Contents" stringByExpandingTildeInPath],
				 @"/Applications/Wine/Wine.bundle/Contents",
				 nil];
	fileManager = [NSFileManager defaultManager];
	tWinePath = nil;
	for (i = 0; i < [winePaths count]; i++) {
		if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/bin/wine", [winePaths objectAtIndex:i]]]) {
			tWinePath = [winePaths objectAtIndex:i];
			i = [winePaths count];
		}
	}
	if (nil == tWinePath) {
		alert = [NSAlert alertWithMessageText:NSLocalizedStringFromTable(@"WBController:AlertWineNotFound:Text", @"Localizable", @"WBController")
								defaultButton:NSLocalizedStringFromTable(@"WBController:AlertWineNotFound:defaultButton", @"Localizable", @"WBController")
							  alternateButton:nil
								  otherButton:nil
					informativeTextWithFormat:NSLocalizedStringFromTable(@"WBController:AlertWineNotFound:informativeTextWithFormat", @"Localizable", @"WBController")];
		[alert runModal];
		[NSApp terminate:self];
	}
	[[NSUserDefaults standardUserDefaults] setObject:tWinePath forKey:@"winePath"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


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
      bundleSignature:(NSString *)tBundleSignature
			   silent:(NSString *)tSilent
		selfcontained:(BOOL)tSelfcontained
			   sender:(id)tSender
			 callback:(SEL)tSelector
{
	NSMutableDictionary *environment;
	NSString *actionName;
	NSString *targetPath;
	NSString *wineBundlePath;
	
	self = [self init];
	if (self) {
		// globals
		bottlerController = tSender;
		callback = tSelector;
		filename = tFilename;
		
		// tFilename
		if (tFilename == nil) {
			if([[[NSProcessInfo processInfo] environment] objectForKey:@"WINEPREFIX"]) {
				tFilename = [NSURL fileURLWithPath:[[[NSProcessInfo processInfo] environment] objectForKey:@"WINEPREFIX"]];
			} else {
				tFilename = [NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] objectForKey:@"prefix"]];
			}
		}
        [tFilename retain];
		
		// tExe
		if (tExe) {
			pathtoExecutable = [tExe stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
		} else {
			pathtoExecutable = @"winefile";
		}
		
		// determine runMode
		if ([tScript isEqual:@"applywinetricks.sh"]) {
			runMode = BottlerRunModeWinetricks;
			actionName = @"Applying Winetricks";
		} else {
			if ([pathtoExecutable isEqual:@"notneeded"]) {
				runMode = BottlerRunModePrefix;
			} else {
				runMode = BottlerRunModeApp;
			}
			[[NSFileManager defaultManager] removeItemAtURL:filename error:NULL];
			actionName = [NSString stringWithFormat:@"Creating \"%@\"", [[tFilename path] lastPathComponent]];
		}
		
		installAction = [[KBActionWindow sharedKBActionWindow] addActionWithTitle:actionName withDescription:@"Waiting..." withIcon:nil withAbortSelector:@selector(abort:) forTarget:self];
		[installAction setProgress:0.0];
		
		// don't brake the dictionary with nil
		if (tScript == nil)
			tScript = @"default.sh";
		if (tTemplate == nil) {
			tTemplate = @"";
		} else {
			[installAction setProgress:5.0];
			[installAction setDescription:@"Copying template..."];
			targetPath = [NSString stringWithFormat:@"%@/Contents/Resources", [tFilename path]];
            //[[NSFileManager defaultManager] createDirectoryAtURL:[NSURL fileURLWithPath:[targetPath stringByDeletingLastPathComponent]] withIntermediateDirectories:YES attributes:nil error:NULL];
            [[NSFileManager defaultManager] createDirectoryAtPath:[targetPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:NULL];
            [[NSFileManager defaultManager]
                copyItemAtURL:[NSURL fileURLWithPath:tTemplate]
                toURL:[NSURL fileURLWithPath:targetPath]
                error:nil];
		}
		if (tInstallerURL == nil)
			tInstallerURL = @"";
		if (tInstallerName == nil)
			tInstallerName = @"";
		if (tInstallerIsZipped == nil)
			tInstallerIsZipped = @"0";
		if (tInstallerArguments == nil)
			tInstallerArguments = @"";
		if (tWinetricks == nil)
			tWinetricks = @"";
		if (tOverrides == nil)
			tOverrides = @"";
		if (tExeArguments == nil)
			tExeArguments = @"";
		if (tBundleVersion == nil)
			tBundleVersion = @"1.0";
		if (tBundleIdentifier == nil)
			tBundleIdentifier = @"org.kronenberg.winebottler";
        if (tBundleSignature != nil && ![tBundleSignature isEqual:@""]) {
            bundleSignature = tBundleSignature;
        } else {
            bundleSignature = nil;
        }
		if (tSilent == nil)
			tSilent = @"";
		if (tSelfcontained) {
			[installAction setProgress:5.0];
			[installAction setDescription:@"Copying Wine binaries..."];
			NSString *winePath;
			winePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"winePath"];
			wineBundlePath = [winePath substringToIndex:[winePath rangeOfString:@"Wine.app"].location + 8];
            NSError *error;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/Contents/Resources", [filename path]] withIntermediateDirectories:YES attributes:nil error:&error])
                NSLog(@"Error %@", error);
            if (![[NSFileManager defaultManager]
                copyItemAtURL:[NSURL fileURLWithPath:wineBundlePath]
                toURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Contents/Resources/Wine.bundle", [filename path]]]
                error:&error])
                NSLog(@"Error %@", error);
		}

		task = [[NSTask alloc] init];
		
		// Pipes
		[task setStandardOutput:stdPipe];
		[task setStandardError:errPipe];
		
		environment = [NSMutableDictionary dictionaryWithObjects:
							  [NSArray arrayWithObjects:
							   [NSString stringWithFormat:@"%@/bin:%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"winePath"], [[[NSProcessInfo processInfo] environment] objectForKey:@"PATH"]],
							   [NSString stringWithFormat:@"%@/bin", [[NSUserDefaults standardUserDefaults] objectForKey:@"winePath"]], // WINEPATH
							   [NSString stringWithFormat:@"%@/lib:/usr/lib", [[NSUserDefaults standardUserDefaults] objectForKey:@"winePath"]], // DYLD_FALLBACK_LIBRARY_PATH
							   [NSString stringWithFormat:@"%@/lib", [[NSUserDefaults standardUserDefaults] objectForKey:@"winePath"]], // LD_LIBRARY_PATH
							   [NSString stringWithFormat:@"%@/etc/fonts/fonts.conf", [[NSUserDefaults standardUserDefaults] objectForKey:@"winePath"]], // FONTCONFIG_FILE
							   NSUserName(),									// USER
							   NSHomeDirectory(),								// HOME
							   [(NSString*)CSCopyMachineName() autorelease],    // COMPUTERNAME
							   
							   [[NSBundle bundleForClass:[self class]] resourcePath], // BUNDLERESOURCEPATH
							   [tFilename path],								// BOTTLE
							   
							   tTemplate,										// TEMPLATE
							   tInstallerURL,									// INSTALLER_URL
							   tInstallerName,									// INSTALLER_NAME
							   tInstallerIsZipped,								// INSTALLER_IS_ZIPPED
							   tInstallerArguments,								// INSTALLER_ARGUMENTS
							   tWinetricks,										// WINETRICKS_ITEMS
							   tOverrides,										// DLL_OVERRIDES
							   pathtoExecutable,								// EXECUTABLE_PATH
							   tExeArguments,									// EXECUTABLE_ARGUMENTS
							   tBundleVersion,									// EXECUTABLE_VERSION
							   tBundleIdentifier,								// BUNDLE_IDENTIFIER
							   tSilent,											// SILENT
							   nil]
														   forKeys:
							  [NSArray arrayWithObjects:
                               @"PATH",
							   @"WINEPATH",
							   @"DYLD_FALLBACK_LIBRARY_PATH",
							   @"LD_LIBRARY_PATH",
							   @"FONTCONFIG_FILE",
							   @"USER",
							   @"HOME",
							   @"COMPUTERNAME",
							   
							   @"BUNDLERESOURCEPATH",
							   @"BOTTLE",
							   
							   @"TEMPLATE",
							   
							   @"INSTALLER_URL",
							   @"INSTALLER_NAME",
							   @"INSTALLER_IS_ZIPPED",
							   @"INSTALLER_ARGUMENTS",
							   
							   @"WINETRICKS_ITEMS",
							   @"DLL_OVERRIDES",
							   
							   @"EXECUTABLE_PATH",
							   @"EXECUTABLE_ARGUMENTS",
							   @"EXECUTABLE_VERSION",
							   
							   @"BUNDLE_IDENTIFIER",
							   @"SILENT",
							   nil]];
		
		// proxies?
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"proxiesUseHttp"]) {
			[environment setObject:[NSString stringWithFormat:@"%@:%@",
									[[NSUserDefaults standardUserDefaults] objectForKey:@"proxiesHostHttp"],
									[[NSUserDefaults standardUserDefaults] objectForKey:@"proxiesPortHttp"]] forKey:@"http_proxy"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"proxiesUseHttps"]) {
			[environment setObject:[NSString stringWithFormat:@"%@:%@",
									[[NSUserDefaults standardUserDefaults] objectForKey:@"proxiesHostHttps"],
									[[NSUserDefaults standardUserDefaults] objectForKey:@"proxiesPortHttps"]] forKey:@"https_proxy"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"proxiesUseFtp"]) {
			[environment setObject:[NSString stringWithFormat:@"%@:%@",
									[[NSUserDefaults standardUserDefaults] objectForKey:@"proxiesHostFtp"],
									[[NSUserDefaults standardUserDefaults] objectForKey:@"proxiesPortFtp"]] forKey:@"ftp_proxy"];
		}
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"proxiesUseSocks5"]) {
			[environment setObject:[NSString stringWithFormat:@"%@:%@",
									[[NSUserDefaults standardUserDefaults] objectForKey:@"proxiesHostSocks5"],
									[[NSUserDefaults standardUserDefaults] objectForKey:@"proxiesPortSocks5"]] forKey:@"socks5_proxy"];
		}
		
		// now set environment
		[task setEnvironment:environment];
		
		[task setCurrentDirectoryPath:[NSString stringWithFormat:@"%@/bin", [[NSUserDefaults standardUserDefaults] objectForKey:@"winePath"]]];
		[task setLaunchPath:@"/bin/sh"];
		[task setArguments:[NSArray arrayWithObject:[NSString stringWithFormat:@"%@/%@", [[NSBundle bundleForClass:[self class]] resourcePath], tScript]]];
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
	if (task)
		[task release];
	if (installAction)
		[[KBActionWindow sharedKBActionWindow] removeAction:installAction];
	if (stringBuffer)
		[stringBuffer release];
	if (log)
		[log release];
    if (filename)
        [filename release];
	[super dealloc];
}


- (void) readFromStdPipe:(NSNotification *)notification
{
	NSUInteger loc;
	NSRange range;
	NSString *line;
	
	[stringBuffer appendString:[[[NSString alloc] initWithData:[[notification userInfo] objectForKey:NSFileHandleNotificationDataItem] encoding:NSASCIIStringEncoding] autorelease]];
	while ((loc = [stringBuffer rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r"]].location) != NSNotFound) {
		line = [stringBuffer substringWithRange:NSMakeRange(0, loc + 1)];
		[stringBuffer setString:[stringBuffer substringFromIndex:loc + 1]];
	
		[log appendString:line];
		NSLog(@"%@", line);

		range = [line rangeOfString:@"###FINISHED###"];
		if (range.location != NSNotFound) {
			exitMode = BottlerExitModeNormal;
			[self abort:self];
			return;
		} else {
			range = [line rangeOfString:@"###ERROR###"];
			if (range.location != NSNotFound) {
				exitMode = BottlerExitModeError;
				[self abort:self];
				return;
			} else {
				range = [line rangeOfString:@"###BOTTLING###"];
				if (range.location != NSNotFound) {
					percent += 5.0;
					[installAction setProgress:percent];
					[installAction setDescription:[line substringFromIndex:15]];
				}
			}
		}
	}
	if (task) {
		if ([task isRunning]) {
			[[notification object] readInBackgroundAndNotify];
		}
	}
}


- (void) readFromErrPipe:(NSNotification *)notification
{
	NSString *line;

	line = [[[NSString alloc] initWithData:[[notification userInfo] objectForKey:NSFileHandleNotificationDataItem] encoding:NSASCIIStringEncoding] autorelease];
	[log appendString:line];
    if (task) {
		if ([task isRunning]) {
			[[notification object] readInBackgroundAndNotify];
		}
	}
}


- (void) checkATaskStatus:(NSNotification *)aNotification
{
	W_DEBUG(@"checkATaskStatus");
	
	if ([[aNotification object] isEqual:task]) {
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		if (exitMode == BottlerExitModeNormal) {
			if ([pathtoExecutable isEqual:@"winefile"]) {
				[self findExe:self];
				return;
			}
		}
		[self finish:self];
	}
}


- (IBAction) abort:(id)sender
{
	if ([task isRunning]) {
		[task terminate];
	}
}


- (IBAction) findExe:(id)sender
{
	int i;
	NSArray *files;
	NSMutableArray *exeFiles;
	
    [NSBundle loadNibNamed:@"WBottler" owner:self];

	exeFiles = [NSMutableArray arrayWithCapacity:2];
	files = [[NSFileManager defaultManager] subpathsAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/wineprefix/drive_c/", [filename path]]];
	for (i = 0; i < [files count]; i++) {
		if ([[[files objectAtIndex:i] pathExtension] rangeOfString:@"exe" options:NSCaseInsensitiveSearch].location != NSNotFound) {
			if (
				(![[[[files objectAtIndex:i] pathComponents] objectAtIndex:0] isEqual:@"windows"]) &&
				(![[[files objectAtIndex:i] stringByDeletingLastPathComponent] isEqual:@"Internet Explorer"]) &&
				(![[[[files objectAtIndex:i] lastPathComponent] substringToIndex:4] isEqual:@"unin"]) &&
				(![[[[files objectAtIndex:i] lastPathComponent] substringToIndex:4] isEqual:@"inst"]) &&
				(![[[[files objectAtIndex:i] lastPathComponent] substringToIndex:5] isEqual:@"setup"])
			) {
				[exeFiles addObject:[files objectAtIndex:i]];
			}
		}
	}
	for (i = 0; i < [exeFiles count]; i++) {
		[exeSelector addItemWithTitle:[exeFiles objectAtIndex:i]];
	}
	[exeSelector selectItemAtIndex:[exeFiles count]];
	
	[NSApp beginSheet:findExePanel
	   modalForWindow:[[KBActionWindow sharedKBActionWindow] window]
        modalDelegate:self
	   didEndSelector:nil
		  contextInfo:nil];
}


- (IBAction)foundExe:(id)sender
{	
	NSString *plist;
	NSStringEncoding encoding;
	
	pathtoExecutable = [NSString stringWithFormat:@"C:\\%@", [exeSelector titleOfSelectedItem]];
	plist = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Info.plist", [filename path]] usedEncoding:&encoding error:nil];
	plist = [plist stringByReplacingOccurrencesOfString:@"winefile" withString:[pathtoExecutable stringByReplacingOccurrencesOfString:@"\\" withString:@"/"]];
	[plist writeToFile:[NSString stringWithFormat:@"%@/Contents/Info.plist", [filename path]] atomically:NO encoding:encoding error:nil];
	
    [NSApp endSheet:findExePanel];
	[findExePanel orderOut:self];
	[self finish:self];
}


- (void) callCallback:(BOOL)success
{
	NSInvocation *invocation;
	
	invocation = [NSInvocation invocationWithMethodSignature:[[bottlerController class] instanceMethodSignatureForSelector:callback]];
	[invocation setTarget:bottlerController];
	[invocation setSelector:callback];
	[invocation setArgument:&success atIndex:2];
	[invocation invoke];
}


- (IBAction) finish:(id)sender
{
	NSString *path;
	NSAlert *alert;
	NSTask *icontask;
    NSPipe *outpipe;
    NSPipe *errpipe;
    NSData *outdata;
    NSData *errdata;
	
	alert = nil;
	
	switch (exitMode) {
			
			
			
		case BottlerExitModeNormal:
			[installAction setProgress:100.0];
			
			// add Icon
			if (runMode == BottlerRunModeApp) {
				icontask = [[NSTask alloc] init];
				[icontask setEnvironment:[NSDictionary dictionaryWithObjects:
									  [NSArray arrayWithObjects:
									   [NSString stringWithFormat:@"%@/Contents/Resources/wineprefix/drive_c/%@", [filename path], [[[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Info.plist", [filename path]]] objectForKey:@"WineProgramPath"] substringFromIndex:3]], // PATH_TO_EXECUTABLE
									   [NSString stringWithFormat:@"%@/Contents/Resources/Icon.icns", [filename path]],
									   nil]
																 forKeys:
									  [NSArray arrayWithObjects:
									   @"PATH_TO_EXECUTABLE",
									   @"PATH_TO_ICON",
									   nil]]];
				[icontask setLaunchPath:@"/bin/sh"];
				[icontask setCurrentDirectoryPath:[[NSBundle bundleForClass:[self class]] resourcePath]];
				[icontask setArguments:[NSArray arrayWithObject:[NSString stringWithFormat:@"%@/icon.sh", [[NSBundle bundleForClass:[self class]] resourcePath]]]];
				[icontask launch];
				[icontask waitUntilExit];
				[icontask release];
                
                // codesign
                if (bundleSignature) {
                    NSLog(@"bundleSignature: %@ %@", bundleSignature, [filename path]);
                    icontask = [[NSTask alloc] init];
                    [icontask setLaunchPath:@"/usr/bin/codesign"];
                    [icontask setCurrentDirectoryPath:[[NSBundle bundleForClass:[self class]] resourcePath]];
                    [icontask setArguments:[NSArray arrayWithObjects:
                                            @"-s",
                                            bundleSignature,
                                            [filename path],
                                            nil]];
                    outpipe = [NSPipe pipe];
                    [icontask setStandardOutput:outpipe];
                    errpipe = [NSPipe pipe];
                    [icontask setStandardError:errpipe];
                    
                    [icontask launch];
                    
                    outdata = [[outpipe fileHandleForReading] readDataToEndOfFile];
                    errdata = [[errpipe fileHandleForReading] readDataToEndOfFile];
                    
                    
                    [icontask waitUntilExit];
                    [icontask release];
                    
                    if ([outdata length] || [errdata length]) {
                        alert = [NSAlert alertWithMessageText:@"Can't Codesign"
                                                defaultButton:@"OK"
                                              alternateButton:nil
                                                  otherButton:nil
                                    informativeTextWithFormat:@"%@ %@",
                                                               [[[NSString alloc] initWithData:outdata encoding:NSUTF8StringEncoding] autorelease],
                                                               [[[NSString alloc] initWithData:errdata encoding:NSUTF8StringEncoding] autorelease]];
                        [alert runModal];
                    }
                }
			}
            
            
            
   //         codesign -s "$PLC_CODESIGN" "$PLC_PRODUCT_DIR/$PLC_PRODUCT_NAME.app" >/dev/null 2>"$PLC_TEMP_DIR/log"
			
			// finish
			if (runMode != BottlerRunModeWinetricks) {
				alert = [NSAlert alertWithMessageText:@"Prefix created sucessfully."
										defaultButton:nil
									  alternateButton:nil
										  otherButton:nil
							informativeTextWithFormat:@""];
			} else {
				alert = [NSAlert alertWithMessageText:@"Winetricks applied sucessfully."
										defaultButton:nil
									  alternateButton:nil
										  otherButton:nil
							informativeTextWithFormat:@""];
			}
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"WineBottlerPrefixesChanged" object:nil];
			break;
			
			
			
		case BottlerExitModeAbort:
			if (runMode != BottlerRunModeWinetricks)
				[[NSFileManager defaultManager] removeItemAtURL:filename error:NULL];
			path = [NSString stringWithFormat:@"%@/Desktop/%@_install.log", NSHomeDirectory(), [[[filename path] lastPathComponent] stringByDeletingPathExtension]];
			[log appendString:[NSString stringWithFormat:@"Task returned with status %d.", [task terminationStatus]]];
			[log writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
			[[NSWorkspace sharedWorkspace] openFile:path withApplication:@"Console"];
			alert = [NSAlert alertWithMessageText:@"Prefix creation aborted"
									defaultButton:nil
								  alternateButton:nil
									  otherButton:nil
						informativeTextWithFormat:@""];
			break;
			
			
			
		case BottlerExitModeError:
			if (runMode != BottlerRunModeWinetricks)
				[[NSFileManager defaultManager] removeItemAtURL:filename error:NULL];
			path = [NSString stringWithFormat:@"%@/Desktop/%@_install.log", NSHomeDirectory(), [[[filename path] lastPathComponent] stringByDeletingPathExtension]];
			[log appendString:[NSString stringWithFormat:@"Task returned with status %d.", [task terminationStatus]]];
			[log writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
			[[NSWorkspace sharedWorkspace] openFile:path withApplication:@"Console"];
			alert = [NSAlert alertWithMessageText:@"Prefix creation exited with error"
									defaultButton:nil
								  alternateButton:nil
									  otherButton:nil
						informativeTextWithFormat:@"You find a logfile to help with debugging on your desktop."];
			break;
	}
	if (nil != alert) {
		[alert beginSheetModalForWindow:[[KBActionWindow sharedKBActionWindow] window]
						  modalDelegate:self
						 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
							contextInfo:nil];
	}
}


- (void) alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	// get rid of window, as the callback will delay the release
	[[alert window] orderOut:self];
	if (installAction)
		[[KBActionWindow sharedKBActionWindow] removeAction:installAction];
	installAction = nil;
	
	// callback
	if (callback != nil) {
		if (exitMode == BottlerExitModeNormal) {
			[self callCallback:YES];
		} else {
			[self callCallback:NO];
		}
	}
	[self release];
}
@end
