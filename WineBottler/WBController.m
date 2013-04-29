/*
 * WBController.m
 * of the 'WineBottler' target in the 'WineBottler' project
 *
 * Copyright 2012 Mike Kronenberg
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



#import "WBController.h"
#include <sys/stat.h>



@implementation WBController
- (id) init
{
	self = [super init];
	if (self) {
        
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
	}
	return self;
}


- (void) dealloc
{
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
