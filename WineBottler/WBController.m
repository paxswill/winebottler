//
//  WBController.m
//  WineBottler
//
//  Created by Mike Kronenberg on 31.03.09.
//  Copyright 2009 Kronenberg Informatik Lösungen. All rights reserved.
//

#import "WBController.h"

#include <sys/stat.h>



@implementation WBController
- (id) init
{
	self = [super init];
	if (self) {
/*		
		// try to launch hidden X11
		[[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:@"org.x.X11"
															 options:
									  additionalEventParamDescriptor:nil
													launchIdentifier:nil];
		[[NSWorkspace sharedWorkspace] launchApplication:@"X11.app" showIcon:NO autolaunch:NO];
*/		
		//userdefauts
		[[NSUserDefaults standardUserDefaults] registerDefaults:
		 [NSDictionary dictionaryWithObjects:
		  [NSArray arrayWithObjects:
		   @"",																	// winePath
		   [NSString stringWithFormat:@"%@/Wine Files", NSHomeDirectory()],		// prefix
		   [[[NSArray alloc] init] autorelease],								// knownPrefixes
		   [NSNumber numberWithBool:YES],										// predefinedExplanation
		   [NSNumber numberWithBool:YES],										// prefixExplanation
		   
		   [NSNumber numberWithBool:NO],										// proxiesUseHttp
		   @"127.0.0.1",
		   @"80",
		   [NSNumber numberWithBool:NO],										// proxiesUseHttps
		   @"127.0.0.1",
		   @"443",
		   [NSNumber numberWithBool:NO],										// proxiesUseFtp
		   @"127.0.0.1",
		   @"20",
		   [NSNumber numberWithBool:NO],										// proxiesUseSocks5
		   @"127.0.0.1",
		   @"1080",
		   
		   nil]
									   forKeys:
		  [NSArray arrayWithObjects:
		   @"winePath",
		   @"prefix",
		   @"knownPrefixes",
		   @"predefinedExplanation",
		   @"prefixExplanation",
		   @"proxiesUseHttp",
		   @"proxiesHostHttp",
		   @"proxiesPortHttp",
		   @"proxiesUseHttps",
		   @"proxiesHostHttps",
		   @"proxiesPortHttps",
		   @"proxiesUseFtp",
		   @"proxiesHostFtp",
		   @"proxiesPortFtp",
		   @"proxiesUseSocks5",
		   @"proxiesHostSocks5",
		   @"proxiesPortSocks5",
			 
		   nil]]];
        userDefaults = [NSUserDefaults standardUserDefaults];
//		[self findWine];
	}
	return self;
}


- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	// save defaults
    [userDefaults synchronize];
	
	[super dealloc];
}


- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	// change to custom page and enter filename
	[wineBottlerController showCustom:self];
	[installer setStringValue:filename];
	[self showBottler:self];
	return true;
}



#pragma mark -
#pragma mark windows and windows delegate
- (IBAction) showBottler:(id)sender
{
	[bottlerWindow makeKeyAndOrderFront:self];
}


- (IBAction) showPreferences:(id)sender
{
	[preferencesWindow makeKeyAndOrderFront:self];
}



#pragma mark -
#pragma mark getters & setters
- (NSUserDefaults *) userDefaults {return userDefaults;}
@end
