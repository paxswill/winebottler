/*
 * WPrefixController.m
 * of the 'WineStatus' target in the 'WineBottler' project
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



#import "WPrefixController.h"
#import "WBottlerController.h"
#import <WBottler/WBottler.h>



@implementation WPrefixController
- (id) init
{

	self = [super init];
	if (self) {
		foundPrefixes = [[NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"knownPrefixes"]] retain];
		
		// we want to be informed about new search results
		
		// we want to be notified
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(queryForPrefixes:) name:@"WineBottlerPrefixesChanged" object:nil];	
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryFinished:) name:NSMetadataQueryDidFinishGatheringNotification object:query];	
	}
	return self;
}


- (void) dealloc
{
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[query release];
	[foundPrefixes release];
	[super dealloc];
}


- (void) awakeFromNib
{
	[table setTarget:self];
	[table setDoubleAction:@selector(tableDoubleClick:)];
	[table registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
	[self setRow];
	[self queryForPrefixes:self];
}


- (void) setRow
{
	int i;
	
	for (i = 0; i < [foundPrefixes count]; i++) {
		if ([[foundPrefixes objectAtIndex:i] isEqual:[[NSUserDefaults standardUserDefaults] objectForKey:@"prefix"]]) {
			[table selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
		}
	}
}



#pragma mark -
#pragma mark NSQuery callback
- (IBAction) queryForPrefixes:(id)sender
{
	int i;
	NSUserDefaults *userDefaults;
	NSString *path;
	NSMutableArray *knownPrefixes;
	NSPredicate *predicate;
	
	userDefaults = [NSUserDefaults standardUserDefaults];

	// prepare UI
	[queryProgressText setHidden:FALSE];
	[queryProgressIndicator startAnimation:self];
	[buttonReload setHidden:TRUE];
	
	// remove obsolete entries
	knownPrefixes = [[[userDefaults objectForKey:@"knownPrefixes"] mutableCopy] autorelease];
	for (i = [knownPrefixes count] -1; i > -1; i--) {
		if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/system.reg", [knownPrefixes objectAtIndex:i]]]) {
			NSLog(@"remove: %@", [knownPrefixes objectAtIndex:i]);
			[knownPrefixes removeObjectAtIndex:i];
		}
	}

	// default .wine entry?
	path = [@"~/.wine/system.reg" stringByExpandingTildeInPath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [path stringByDeletingLastPathComponent];
		if (![knownPrefixes containsObject:path]) {
			[knownPrefixes addObject:path];
		}
	}

	[userDefaults setObject:knownPrefixes forKey:@"knownPrefixes"];
	[userDefaults synchronize];

	// search new entries
	query = [[NSMetadataQuery alloc] init];
	[query setDelegate:self];
	[queryProgressIndicator startAnimation:self];
	predicate = [NSPredicate predicateWithFormat:@"kMDItemDisplayName ENDSWITH 'system.reg' OR kMDItemDisplayName ENDSWITH '.app'", nil];
	[query setPredicate:predicate];
	[query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryLocalComputerScope]];
	[query startQuery];	
}


- (void)queryFinished:(NSNotification*)note
{
	int i;
	NSUserDefaults *userDefaults;
	NSArray *searchResults;
	NSString *path;
	NSMutableArray *knownPrefixes;
	
	userDefaults = [NSUserDefaults standardUserDefaults];
	knownPrefixes = [[[userDefaults objectForKey:@"knownPrefixes"] mutableCopy] autorelease];
	searchResults = [(NSMetadataQuery*)[note object] results];
	
	for (i = 0; i < [searchResults count]; i++) {
		if ([[[[searchResults objectAtIndex:i] valueForAttribute: (NSString *)kMDItemPath] lastPathComponent] isEqual:@"system.reg"]) {
			path = [[[[searchResults objectAtIndex:i] valueForAttribute: (NSString *)kMDItemPath] stringByResolvingSymlinksInPath] stringByDeletingLastPathComponent];
			if (![knownPrefixes containsObject:path]) {
				[knownPrefixes addObject:path];
			}
		} else if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/system.reg", [[searchResults objectAtIndex:i] valueForAttribute: (NSString *)kMDItemPath]]]) {
			path = [NSString stringWithFormat:@"%@/Contents/Resources", [[searchResults objectAtIndex:i] valueForAttribute: (NSString *)kMDItemPath]];
			if (![knownPrefixes containsObject:path]) {
				[knownPrefixes addObject:path];
			}
		}
	}
	[userDefaults setObject:knownPrefixes forKey:@"knownPrefixes"];
	[userDefaults synchronize];
	
	[queryProgressText setHidden:TRUE];
	[queryProgressIndicator stopAnimation:self];
	[buttonReload setHidden:FALSE];
	
	[foundPrefixes release];
	foundPrefixes = [[NSArray alloc] initWithArray:knownPrefixes];
	
	[table reloadData];
}



#pragma mark -
#pragma mark NSTableView delegates
-(int)numberOfRowsInTableView:(NSTableView *)table
{	
	return [foundPrefixes count];
}


- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	NSString *path;
	NSString *name;
	NSRange range;
	
	range = [[foundPrefixes objectAtIndex:rowIndex] rangeOfString:@".app"];
	if (range.location == NSNotFound) {
		path = [foundPrefixes objectAtIndex:rowIndex];
		name = [NSString stringWithFormat:@"%@ (Working copy)", [path lastPathComponent]];
	} else {
		path = [[foundPrefixes objectAtIndex:rowIndex] substringToIndex:range.location + 4];
		name = [NSString stringWithFormat:@"%@ (Template)", [[path lastPathComponent] substringToIndex:[[path lastPathComponent] length] - 4]];
	}
	
    if ([[aTableColumn identifier] isEqualTo: @"prefix"]) {
		return name;
    } else if ([[aTableColumn identifier] isEqualTo: @"icon"]) {
		return [[NSWorkspace sharedWorkspace] iconForFile:path];
	}
    return nil;
}



#pragma mark -
#pragma mark NSTableView clicks
- (void) tableDoubleClick:(id)sender
{

}


- (IBAction) search:(id)sender
{
	NSPredicate *predicate;
	NSString *search;
	
	if (foundPrefixes) {
		search = [searchField stringValue];
		if (foundPrefixes)
			[foundPrefixes release];
		if ([search isEqual:@""]) {
			foundPrefixes = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"knownPrefixes"]];
		} else {
			predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", search];
			foundPrefixes = [[[NSUserDefaults standardUserDefaults] objectForKey:@"knownPrefixes"] filteredArrayUsingPredicate:predicate];
		}
		[foundPrefixes retain];
		[table reloadData];
	}
}


- (IBAction) changePrefix:(id)sender
{
    if ([table clickedRow] > -1) { // no empty line selection
		[controller changePrefixTo:[foundPrefixes objectAtIndex:[table selectedRow]]];
	}
}


- (IBAction) createNewPrefix:(id)sender
{
	NSMutableArray *knownPrefixes;
	NSSavePanel *savePanel;
    
    knownPrefixes = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"knownPrefixes"] mutableCopy] autorelease];
	
	savePanel = [NSSavePanel savePanel];
	[savePanel setTitle:@"Create new wine prefix."];
	[savePanel setMessage:@"This Folder will contain the files needed to run your applications."];
	[savePanel setCanCreateDirectories:YES];
	[savePanel setAllowedFileTypes:nil];
    [savePanel setNameFieldStringValue:@"My new Wine prefix"];
    [savePanel beginSheetModalForWindow:[table window] completionHandler:^(NSInteger returnCode) {
        if (returnCode == NSOKButton) {
            [[NSUserDefaults standardUserDefaults] setObject:[[savePanel URL] path] forKey:@"prefix"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/system.reg", [[savePanel URL] path]]]) {
                [[[WBottler alloc] initWithScript:@"customprefix.sh"
                                              URL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"prefix"]]
                                         template:nil
                                     installerURL:nil
                                installerIsZipped:nil
                                    installerName:nil
                               installerArguments:nil
                                       winetricks:nil
                                        overrides:nil
                                              exe:@"notneeded"
                                     exeArguments:nil
                                    bundleVersion:nil
                                 bundleIdentifier:nil
                                           silent:nil
                                    selfcontained:NO
                                           sender:bottlerController
                                         callback:nil] autorelease];
            }
            if (![knownPrefixes containsObject:[[savePanel URL] path]]) {
                [knownPrefixes addObject:[[savePanel URL] path]];
                [[NSUserDefaults standardUserDefaults] setObject:knownPrefixes forKey:@"knownPrefixes"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [table reloadData];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self setRow];
        }
    }];
}


- (void) deleteAtRow:(int)row
{
	NSRange range;
	NSString *path;
	NSAlert *alert;
	
	range = [[foundPrefixes objectAtIndex:row] rangeOfString:@".app"];
	if (range.location == NSNotFound) {
		path = [foundPrefixes objectAtIndex:row];
	} else {
		path = [[foundPrefixes objectAtIndex:row] substringToIndex:range.location + 4];
	}
	alert = [[NSAlert alloc] init];
	[alert setMessageText:[NSString stringWithFormat:@"Remove the prefix \"%@\"?", [path lastPathComponent]]];
	[alert setInformativeText:[NSString stringWithFormat:@"Are you sure you want to remove \"%@\" and all it's files and apps?", [path lastPathComponent]]];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert addButtonWithTitle:@"Remove"];
	[alert addButtonWithTitle:@"Cancel"];
	[alert beginSheetModalForWindow:[bottlerController bottlerWindow]
					  modalDelegate:self
					 didEndSelector:@selector(deletePrefixAlertDidEnd:returnCode:contextInfo:)
						contextInfo:[foundPrefixes objectAtIndex:row]];
}


- (void)deletePrefixAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	NSRange range;
	NSString *path;
	NSString *appName;
	
	switch (returnCode) {
		case NSAlertFirstButtonReturn:
			range = [(NSString *)contextInfo rangeOfString:@".app"];
			if (range.location == NSNotFound) {
				path = (NSString *)contextInfo;
			} else {
				path = [(NSString *)contextInfo substringToIndex:range.location + 4];
			}
			[[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:path] error:nil];
			
			// if we remove a copied prefix, we remove all the other files aswell
			range = [(NSString *)contextInfo rangeOfString:@"Library/Application Support/wine/prefixs/"];
			if (range.location == NSNotFound) {
				appName = [(NSString *)contextInfo  lastPathComponent];
				// ~/Library/preferences/
				path = [[NSString stringWithFormat:@"~/Library/Preferences/org.kronenberg.winebottler_%@.plist", appName] stringByExpandingTildeInPath];
				[[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:path] error:nil];
				// ~/.xinitrc.d/
				path = [[NSString stringWithFormat:@"~/.xinitrc.d/org.kronenberg.winebottler_%@.sh", appName] stringByExpandingTildeInPath];
				[[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:path] error:nil];
			}
			[[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:path] error:nil];
			
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"WineBottlerPrefixesChanged" object:nil];
			break;
		case NSAlertSecondButtonReturn:
			break;
	}
}


- (void) showInFinderAtRow:(int)row
{
	NSRange range;
	NSString *path;
	
	range = [[foundPrefixes objectAtIndex:row] rangeOfString:@".app"];
	if (range.location == NSNotFound) {
		path = [foundPrefixes objectAtIndex:row];
	} else {
		path = [[[foundPrefixes objectAtIndex:row] substringToIndex:range.location + 4] stringByDeletingLastPathComponent] ;
	}
	[[NSWorkspace sharedWorkspace] openFile:path];
}
@end
