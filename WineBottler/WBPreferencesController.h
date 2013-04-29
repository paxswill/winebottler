//
//  WBPreferencesController.h
//  WineBottler
//
//  Created by Mike Kronenberg on 17.04.09.
//  Copyright 2009 Kronenberg Informatik Lösungen. All rights reserved.
//

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
