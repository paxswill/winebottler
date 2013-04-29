//
//  WSPreferencesController.m
//  WineBottler
//
//  Created by Mike Kronenberg on 17.04.09.
//  Copyright 2009 Kronenberg Informatik Lösungen. All rights reserved.
//

#import "WSPreferencesController.h"



#define TOOLBAR_HEIGHT 76



@implementation WSPreferencesController
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
	//	NSLog(@"cocoaControlEditPC: awakeFromNib");
	NSToolbar *preferencesWindowToolbar;
	
	// create Toolbar
	preferencesWindowToolbar = [[[NSToolbar alloc] initWithIdentifier: @"preferencesWindowToolbarIdentifier"] autorelease];
	[preferencesWindowToolbar setAllowsUserCustomization: NO]; //allow customisation
	[preferencesWindowToolbar setAutosavesConfiguration: NO]; //autosave changes
	[preferencesWindowToolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel]; //what is shown
	[preferencesWindowToolbar setSizeMode:NSToolbarSizeModeRegular]; //default Toolbar Size
	[preferencesWindowToolbar setDelegate: self]; // We are the delegate
	[preferencesWindow setToolbar: preferencesWindowToolbar]; // Attach the toolbar to the document window
	
	// update Panel content
	if ([userDefaults boolForKey:@"showWineWindow"]) {
		[showWineWindowButton setState:NSOnState];
	} else {
		[showWineWindowButton setState:NSOffState];
	}
	
	if ([userDefaults boolForKey:@"doLog"]) {
		[logButton setState:NSOnState];
	} else {
		[logButton setState:NSOffState];
	}
	
	// show default panel
	[self showGeneral:self];
	[preferencesWindowToolbar setSelectedItemIdentifier:@"prefixes"];
}



- (void) dealloc
{
	[super dealloc];
}



#pragma mark toolbar
- (void) showGeneral:(id)sender
{
	if ([preferencesViewAdvanced superview]) {
		[preferencesViewAdvanced retain];
		[preferencesViewAdvanced removeFromSuperview];
	}
	
	[preferencesWindow setTitle:@"Wine - General Preferences"];
	[preferencesWindow setFrame:NSMakeRect(
									   [preferencesWindow frame].origin.x,
									   [preferencesWindow frame].origin.y + [preferencesWindow frame].size.height - [preferencesViewGeneral bounds].size.height - TOOLBAR_HEIGHT,
									   [preferencesViewGeneral bounds].size.width,
									   [preferencesViewGeneral bounds].size.height + TOOLBAR_HEIGHT
									   ) display:YES animate:YES];
	
	[[preferencesWindow contentView] addSubview:preferencesViewGeneral];
	[preferencesViewGeneral setFrame:NSMakeRect(0, 0, [preferencesViewGeneral bounds].size.width, [preferencesViewGeneral bounds].size.height)];
	[preferencesWindow setMinSize:NSMakeSize(422, 135 + 21)];
	[preferencesWindow setMaxSize:NSMakeSize(422, 135 + 21)];
}



- (void) showAdvanced:(id)sender
{
	if ([preferencesViewGeneral superview]) {
		[preferencesViewGeneral retain];
		[preferencesViewGeneral removeFromSuperview];
	}
	
	[preferencesWindow setTitle:@"Wine - Advanced Preferences"];
	[preferencesWindow setFrame:NSMakeRect(
										   [preferencesWindow frame].origin.x,
										   [preferencesWindow frame].origin.y + [preferencesWindow frame].size.height - [preferencesViewAdvanced bounds].size.height - TOOLBAR_HEIGHT,
										   [preferencesViewAdvanced bounds].size.width,
										   [preferencesViewAdvanced bounds].size.height + TOOLBAR_HEIGHT
										   ) display:YES animate:YES];
	
	[[preferencesWindow contentView] addSubview:preferencesViewAdvanced];
	[preferencesViewAdvanced setFrame:NSMakeRect(0, 0, [preferencesViewAdvanced bounds].size.width, [preferencesViewAdvanced bounds].size.height)];
	[preferencesWindow setMinSize:NSMakeSize(422, 135 + 21)];
	[preferencesWindow setMaxSize:NSMakeSize(422, 135 + 21)];
}


#pragma mark NSToolbar Delegates
- (NSToolbarItem *) toolbar: (NSToolbar *)toolbar itemForItemIdentifier: (NSString *) itemIdent willBeInsertedIntoToolbar:(BOOL) willBeInserted
{
	NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
	
	if ([itemIdent isEqual: @"general"]) {
		[toolbarItem setLabel: @"General"];
		[toolbarItem setPaletteLabel: @"General"];
		[toolbarItem setToolTip: @"show general preferences"];
		[toolbarItem setImage: [NSImage imageNamed: @"NSPreferencesGeneral"]];
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector( showGeneral: )];
	} else if ([itemIdent isEqual: @"advanced"]) {
		[toolbarItem setLabel: @"Advanced"];
		[toolbarItem setPaletteLabel: @"Advanced"];
		[toolbarItem setToolTip: @"show advanced preferences"];
		[toolbarItem setImage: [NSImage imageNamed: @"NSPreferencesAdvanced"]];
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector( showAdvanced: )];
	} else {
		toolbarItem = nil;
	}
	
	return toolbarItem;
}



- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:
			@"general",
			@"advanced",
			NSToolbarFlexibleSpaceItemIdentifier,
			nil];
}



- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
	return [NSArray arrayWithObjects:
			@"general",
			nil];
}



- (NSArray *) toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:
			@"general",
			@"advanced",
			NSToolbarFlexibleSpaceItemIdentifier,
			nil];	
}



#pragma mark IBActions

- (IBAction) showWineWindow:(id)sender {
	if ([sender state] == NSOnState) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showWineWindow"];
	} else {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"showWineWindow"];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction) changeLogfile:(id)sender
{
	if ([logButton state] == NSOffState) {
		[userDefaults setBool:FALSE forKey:@"doLog"];
	} else {
		[userDefaults setBool:TRUE forKey:@"doLog"];
	}
	[userDefaults synchronize];
	[controller toggleLogFile];
}
@end
