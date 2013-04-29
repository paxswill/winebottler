/*
 * WBPreferencesController.h
 * of the 'WineBottler' target in the 'WineBottler' project
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



@interface WBPreferencesController : NSObject <NSWindowDelegate, NSToolbarDelegate> {
	IBOutlet NSWindow *preferencesWindow;
	IBOutlet NSView *viewGeneral;
	IBOutlet NSView *viewProxies;
	IBOutlet NSView *viewUpdate;
	
	IBOutlet NSButton *explanationPredefined;
	IBOutlet NSButton *explanationPrefix;
	
	IBOutlet NSButton *proxiesUseHttp;
	IBOutlet NSButton *proxiesUseHttps;
	IBOutlet NSButton *proxiesUseFtp;
	IBOutlet NSButton *proxiesUseSocks5;
	IBOutlet NSTextField *proxiesHostHttp;
	IBOutlet NSTextField *proxiesHostHttps;
	IBOutlet NSTextField *proxiesHostFtp;
	IBOutlet NSTextField *proxiesHostSocks5;
	IBOutlet NSTextField *proxiesPortHttp;
	IBOutlet NSTextField *proxiesPortHttps;
	IBOutlet NSTextField *proxiesPortFtp;
	IBOutlet NSTextField *proxiesPortSocks5;
	
	NSUserDefaults *userDefaults;
}
- (IBAction) showGeneral:(id)sender;
- (IBAction) showProxies:(id)sender;
- (IBAction) showUpdate:(id)sender;

- (IBAction) explanationPredefinedSet:(id)sender;
- (IBAction) explanationPrefixSet:(id)sender;

- (IBAction) proxiesAppy:(id)sender;
@end
