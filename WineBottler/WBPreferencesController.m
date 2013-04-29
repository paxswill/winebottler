/*
 * WBPreferencesController.m
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



#import "WBPreferencesController.h"



#define TOOLBAR_HEIGHT 76



@implementation WBPreferencesController
- (id) init
{
	self = [super init];
	if (self) {
		
		// Userdefaults
		userDefaults = [NSUserDefaults standardUserDefaults];
	}
	return self;
}


- (void) awakeFromNib
{
	[preferencesWindow setDelegate:self];
	
	NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier: @"toolbarIdentifier"] autorelease];
	[toolbar setAllowsUserCustomization: NO]; //allow customisation
	[toolbar setAutosavesConfiguration: NO]; //autosave changes
	[toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel]; //what is shown
	[toolbar setSizeMode:NSToolbarSizeModeRegular]; //default Toolbar Size
	[toolbar setDelegate: self]; // We are the delegate
	[preferencesWindow setToolbar: toolbar]; // Attach the toolbar to the document window
	
	[self showUpdate:self];
	[toolbar setSelectedItemIdentifier:@"Update"];
}


- (void) dealloc
{
	[super dealloc];
}



#pragma mark -
#pragma mark IBActions General
- (IBAction) explanationPredefinedSet:(id)sender
{
	if ([explanationPredefined state] == NSOffState) {
		[userDefaults setBool:FALSE forKey:@"predefinedExplanation"];
	} else {
		[userDefaults setBool:TRUE forKey:@"predefinedExplanation"];
	}
	[userDefaults synchronize];
}


- (IBAction) explanationPrefixSet:(id)sender
{
	if ([explanationPrefix state] == NSOffState) {
		[userDefaults setBool:FALSE forKey:@"prefixExplanation"];
	} else {
		[userDefaults setBool:TRUE forKey:@"prefixExplanation"];
	}
	[userDefaults synchronize];
}



#pragma mark -
#pragma mark IBActions Proxies
- (IBAction) proxiesAppy:(id)sender
{
	if ([proxiesUseHttp state] == NSOffState) {
		[userDefaults setBool:FALSE forKey:@"proxiesUseHttp"];
	} else {
		[userDefaults setBool:TRUE forKey:@"proxiesUseHttp"];
	}
	[userDefaults setObject:[proxiesHostHttp stringValue] forKey:@"proxiesHostHttp"];
	[userDefaults setObject:[proxiesPortHttp stringValue] forKey:@"proxiesPortHttp"];
	
	if ([proxiesUseHttps state] == NSOffState) {
		[userDefaults setBool:FALSE forKey:@"proxiesUseHttps"];
	} else {
		[userDefaults setBool:TRUE forKey:@"proxiesUseHttps"];
	}
	[userDefaults setObject:[proxiesHostHttps stringValue] forKey:@"proxiesHostHttps"];
	[userDefaults setObject:[proxiesPortHttps stringValue] forKey:@"proxiesPortHttps"];
	
	if ([proxiesUseFtp state] == NSOffState) {
		[userDefaults setBool:FALSE forKey:@"proxiesUseFtp"];
	} else {
		[userDefaults setBool:TRUE forKey:@"proxiesUseFtp"];
	}
	[userDefaults setObject:[proxiesHostFtp stringValue] forKey:@"proxiesHostFtp"];
	[userDefaults setObject:[proxiesPortFtp stringValue] forKey:@"proxiesPortFtp"];
	
	if ([proxiesUseSocks5 state] == NSOffState) {
		[userDefaults setBool:FALSE forKey:@"proxiesUseSocks5"];
	} else {
		[userDefaults setBool:TRUE forKey:@"proxiesUseSocks5"];
	}
	[userDefaults setObject:[proxiesHostSocks5 stringValue] forKey:@"proxiesHostSocks5"];
	[userDefaults setObject:[proxiesPortSocks5 stringValue] forKey:@"proxiesPortSocks5"];
	
	[userDefaults synchronize];
}



#pragma mark -
#pragma mark preference panes
- (IBAction) showGeneral:(id)sender
{
	// set options
	[userDefaults synchronize];
	if ([userDefaults boolForKey:@"predefinedExplanation"]) {
		[explanationPredefined setState:NSOnState];
	} else {
		[explanationPredefined setState:NSOffState];
	}
	if ([userDefaults boolForKey:@"prefixExplanation"]) {
		[explanationPrefix setState:NSOnState];
	} else {
		[explanationPrefix setState:NSOffState];
	}
	
	// backup views
	if ([viewUpdate superview]) {
		[viewUpdate retain];
		[viewUpdate removeFromSuperview];
	} else if ([viewProxies superview]) {
		[viewProxies retain];
		[viewProxies removeFromSuperview];
	}

	// show view
	[preferencesWindow setTitle:NSLocalizedStringFromTable(@"WBPreferencesController:showGeneral:WindowTitle", @"Localizable", @"WBPreferencesController")];
	[preferencesWindow setFrame:NSMakeRect(
										   [preferencesWindow frame].origin.x,
										   [preferencesWindow frame].origin.y + [preferencesWindow frame].size.height - [viewGeneral bounds].size.height - TOOLBAR_HEIGHT,
										   [viewGeneral bounds].size.width,
										   [viewGeneral bounds].size.height + TOOLBAR_HEIGHT
										   ) display:YES animate:YES];
	[[preferencesWindow contentView] addSubview:viewGeneral];
	[viewGeneral setFrame:NSMakeRect(0, 0, [viewGeneral bounds].size.width, [viewGeneral bounds].size.height)];
}


- (IBAction) showProxies:(id)sender
{
	// set options
	[userDefaults synchronize];
	if ([userDefaults boolForKey:@"proxiesUseHttp"]) {
		[proxiesUseHttp setState:NSOnState];
	} else {
		[proxiesUseHttp setState:NSOffState];
	}
	[proxiesHostHttp setStringValue:[userDefaults objectForKey:@"proxiesHostHttp"]];
	[proxiesPortHttp setStringValue:[userDefaults objectForKey:@"proxiesPortHttp"]];
	
	if ([userDefaults boolForKey:@"proxiesUseHttps"]) {
		[proxiesUseHttps setState:NSOnState];
	} else {
		[proxiesUseHttps setState:NSOffState];
	}
	[proxiesHostHttps setStringValue:[userDefaults objectForKey:@"proxiesHostHttps"]];
	[proxiesPortHttps setStringValue:[userDefaults objectForKey:@"proxiesPortHttps"]];
	
	if ([userDefaults boolForKey:@"proxiesUseFtp"]) {
		[proxiesUseFtp setState:NSOnState];
	} else {
		[proxiesUseFtp setState:NSOffState];
	}
	[proxiesHostFtp setStringValue:[userDefaults objectForKey:@"proxiesHostFtp"]];
	[proxiesPortFtp setStringValue:[userDefaults objectForKey:@"proxiesPortFtp"]];
	
	if ([userDefaults boolForKey:@"proxiesUseSocks5"]) {
		[proxiesUseSocks5 setState:NSOnState];
	} else {
		[proxiesUseSocks5 setState:NSOffState];
	}
	[proxiesHostSocks5 setStringValue:[userDefaults objectForKey:@"proxiesHostSocks5"]];
	[proxiesPortSocks5 setStringValue:[userDefaults objectForKey:@"proxiesPortSocks5"]];
	
	// backup views
	if ([viewGeneral superview]) {
		[viewGeneral retain];
		[viewGeneral removeFromSuperview];
	} else if ([viewUpdate superview]) {
		[viewUpdate retain];
		[viewUpdate removeFromSuperview];
	}
	
	// show view
	[preferencesWindow setTitle:NSLocalizedStringFromTable(@"WBPreferencesController:showGeneral:WindowProxies", @"Localizable", @"WBPreferencesController")];
	[preferencesWindow setFrame:NSMakeRect(
										   [preferencesWindow frame].origin.x,
										   [preferencesWindow frame].origin.y + [preferencesWindow frame].size.height - [viewProxies bounds].size.height - TOOLBAR_HEIGHT,
										   [viewProxies bounds].size.width,
										   [viewProxies bounds].size.height + TOOLBAR_HEIGHT
										   ) display:YES animate:YES];
	[[preferencesWindow contentView] addSubview:viewProxies];
	[viewProxies setFrame:NSMakeRect(0, 0, [viewProxies bounds].size.width, [viewProxies bounds].size.height)];
}


- (IBAction) showUpdate:(id)sender
{
	
	// backup views
	if ([viewGeneral superview]) {
		[viewGeneral retain];
		[viewGeneral removeFromSuperview];
	} else if ([viewProxies superview]) {
		[viewProxies retain];
		[viewProxies removeFromSuperview];
	}
	
	// show view
	[preferencesWindow setTitle:NSLocalizedStringFromTable(@"WBPreferencesController:showUpdate:WindowTitle", @"Localizable", @"WBPreferencesController")];
	[preferencesWindow setFrame:NSMakeRect(
								[preferencesWindow frame].origin.x,
								[preferencesWindow frame].origin.y + [preferencesWindow frame].size.height - [viewUpdate bounds].size.height - TOOLBAR_HEIGHT,
								[viewUpdate bounds].size.width,
								[viewUpdate bounds].size.height + TOOLBAR_HEIGHT
								) display:YES animate:YES];
	
	[[preferencesWindow contentView] addSubview:viewUpdate];
	[viewUpdate setFrame:NSMakeRect(0, 0, [viewUpdate bounds].size.width, [viewUpdate bounds].size.height)];
}



#pragma mark -
#pragma mark NSToolbar Delegates
- (NSToolbarItem *) toolbar: (NSToolbar *)toolbar itemForItemIdentifier: (NSString *) itemIdent willBeInsertedIntoToolbar:(BOOL) willBeInserted
{
	NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
	
	if ([itemIdent isEqual: @"General"]) {
		[toolbarItem setLabel:NSLocalizedStringFromTable(@"WBPreferencesController:TootlbarItem:General:setLabel", @"Localizable", @"WBPreferencesController")];
		[toolbarItem setPaletteLabel: NSLocalizedStringFromTable(@"WBPreferencesController:TootlbarItem:General:setPaletteLabel", @"Localizable", @"WBPreferencesController")];
		[toolbarItem setToolTip:NSLocalizedStringFromTable(@"WBPreferencesController:TootlbarItem:General:setToolTip", @"Localizable", @"WBPreferencesController")];
		[toolbarItem setImage: [NSImage imageNamed: @"Msi.icns"]];
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector( showGeneral: )];
	} else if ([itemIdent isEqual: @"Proxies"]) {
		[toolbarItem setLabel:NSLocalizedStringFromTable(@"WBPreferencesController:TootlbarItem:Proxies:setLabel", @"Localizable", @"WBPreferencesController")];
		[toolbarItem setPaletteLabel: NSLocalizedStringFromTable(@"WBPreferencesController:TootlbarItem:Proxies:setPaletteLabel", @"Localizable", @"WBPreferencesController")];
		[toolbarItem setToolTip:NSLocalizedStringFromTable(@"WBPreferencesController:TootlbarItem:Proxies:setToolTip", @"Localizable", @"WBPreferencesController")];
		[toolbarItem setImage: [NSImage imageNamed: @"Proxies.icns"]];
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector( showProxies: )];
	} else if ([itemIdent isEqual: @"Update"]) {
		[toolbarItem setLabel:NSLocalizedStringFromTable(@"WBPreferencesController:TootlbarItem:Update:setLabel", @"Localizable", @"WBPreferencesController")];
		[toolbarItem setPaletteLabel: NSLocalizedStringFromTable(@"WBPreferencesController:TootlbarItem:Update:setPaletteLabel", @"Localizable", @"WBPreferencesController")];
		[toolbarItem setToolTip:NSLocalizedStringFromTable(@"WBPreferencesController:TootlbarItem:Update:setToolTip", @"Localizable", @"WBPreferencesController")];
		[toolbarItem setImage: [NSImage imageNamed: @"Sparkle.icns"]];
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector( showUpdate: )];
	} else {
		toolbarItem = nil;
	}
	return toolbarItem;
}


- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:
			@"General",
			@"Proxies",
			@"Update",
			nil];
}


- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
	return [NSArray arrayWithObjects:
			@"General",
			@"Proxies",
			@"Update",
			nil];
}


- (NSArray *) toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:
			@"General",
			@"Proxies",
			@"Update",
			nil];	
}
@end
