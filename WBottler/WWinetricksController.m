//
//  WWinetricksController.m
//  WineBottler
//
//  Created by Mike Kronenberg on 20.05.09.
//  Copyright 2009 Kronenberg Informatik Lösungen. All rights reserved.
//

#import "WWinetricksController.h"
#import "WBottler.h"

//#define PREDEFINED_URL @"http://localhost/~mike/winebottler/"
#define PREDEFINED_URL @"http://winebottler.kronenberg.org/winebottler/"
#define WINETRICKS_URL @"http://winetricks.org/winetricks"
#define APPSUPPORT_WINE [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/Wine/"]


@implementation WWinetricksController
- (id) init
{
    BOOL dir;
    NSAlert *alert;
    
	self = [super init];
	if (self) {
        
        // make sure X11 is installed
        if ([[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"org.macosforge.xquartz.X11"]) {
            
        } else if (![[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"org.x.X11"]) {
            alert = [NSAlert alertWithMessageText:@"Wine requires X Window System."
                                    defaultButton:nil
                                  alternateButton:nil
                                      otherButton:nil
                        informativeTextWithFormat:@"You will be asked by OS X to install X11. Please restart the Application after the installation of X11."];
            [alert runModal];
            [[NSWorkspace sharedWorkspace] launchApplication:@"X11"];
            [NSApp terminate:self];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:APPSUPPORT_WINE isDirectory:&dir])
            [[NSFileManager defaultManager] createDirectoryAtPath:APPSUPPORT_WINE withIntermediateDirectories:YES attributes:nil error:nil];
        
		tricks = [[NSMutableArray array] retain];
		foundTricks = [[NSArray array] retain]; 
	}
	return self;
}


- (void) dealloc
{
	if (tricks)
		[tricks release];
	if (foundTricks)
		[foundTricks release];
	[super dealloc];
}


- (void) awakeFromNib {
    [self loadWinetricks:self];
    [NSThread detachNewThreadSelector:@selector(update:) toTarget:self withObject:nil];
}


- (IBAction) update:(id)sender
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // Top-level pool
    
    NSString *string;
    NSData *outdata;
    NSData *errdata;
    NSTask *task;
    NSPipe *outpipe;
    NSPipe *errpipe;
 
    // get a copy of the winetricks
    string = [NSString stringWithContentsOfURL:[NSURL URLWithString:WINETRICKS_URL] encoding:NSUTF8StringEncoding error:nil];
    if (string) {
        [string writeToURL:[NSString stringWithFormat:@"%@winetricks", APPSUPPORT_WINE] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    } else {
        NSLog(@"Can't update winetricks");
    }
    
    // get a copy of the customverbs
    string = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@customverbs", PREDEFINED_URL ]] encoding:NSUTF8StringEncoding error:nil];
    if (string) {
        [string writeToURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@customverbs", APPSUPPORT_WINE]] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    } else {
        NSLog(@"Can't update @customverbs");
    }
    
    // extract verbs
    task = [NSTask new];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:[NSArray arrayWithObject:[[NSBundle bundleForClass:[self class]] pathForResource:@"winetricksextract" ofType:@"sh"]]];
    outpipe = [NSPipe pipe];
    [task setStandardOutput:outpipe];
    errpipe = [NSPipe pipe];
    [task setStandardError:errpipe];
     
    [task launch];
    
    outdata = [[outpipe fileHandleForReading] readDataToEndOfFile];
    errdata = [[errpipe fileHandleForReading] readDataToEndOfFile];
    
    [task waitUntilExit];
    [task release];
    
    if ([outdata length] || [errdata length]) {
        NSLog(@"Can't create winetricks.plist");
        NSLog(@"outdata: %@", [[[NSString alloc] initWithData:outdata encoding:NSUTF8StringEncoding] autorelease]);
        NSLog(@"errdata: %@", [[[NSString alloc] initWithData:errdata encoding:NSUTF8StringEncoding] autorelease]);
    }
    
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"WineBottlerPredefinedChanged" object:nil];
    [self performSelectorOnMainThread:@selector(loadWinetricks:) withObject:nil waitUntilDone:YES];
    
    [pool release];  // Release the objects in the pool.
}


-(IBAction) loadWinetricks:(id)sender
{
    NSArray *wineTrickVerbs;
    
    wineTrickVerbs = [NSArray arrayWithContentsOfURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@winetricks.plist", APPSUPPORT_WINE]]];
    if (wineTrickVerbs) {
		[tricks release];
        tricks = [wineTrickVerbs mutableCopy];
    } else {
        [tricks release];
        tricks = [[NSMutableArray array] retain];
    }
    [foundTricks release];
    foundTricks = [[NSArray arrayWithArray:tricks] retain];
    [table reloadData];
}


- (IBAction) apply:(id)sender
{
	NSString *silent;
	
	if ([silentInstall state] == NSOnState) {
		silent = @"-q";
	} else {
		silent = @"";
	}
	[[[WBottler alloc] initWithScript:@"applywinetricks.sh"
                                  URL:nil
							 template:nil
						 installerURL:nil
					installerIsZipped:nil
						installerName:nil
				   installerArguments:nil
						   winetricks:[self winetricks]
							overrides:nil
								  exe:@"notneeded"
						 exeArguments:nil
						bundleVersion:nil
					 bundleIdentifier:nil
							   silent:silent
						selfcontained:NO
							   sender:self
							 callback:nil] autorelease];
}



#pragma mark -
#pragma mark NSTableView delegates
-(int)numberOfRowsInTableView:(NSTableView *)table
{	
	if (foundTricks)
		return [foundTricks count];
	return 0;
}


- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	if ([[aTableColumn identifier] isEqualTo: @"description"]) {
		if (foundTricks)
			return [[[NSAttributedString alloc] initWithString:[[foundTricks objectAtIndex:rowIndex] objectForKey:@"title"] attributes:[NSDictionary dictionaryWithObject:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] forKey:NSFontAttributeName]] autorelease];
	}
    return nil;
}


- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	if ([[aTableColumn identifier] isEqualTo: @"name"]) {
		if (foundTricks) {
			[aCell setTitle:[[foundTricks objectAtIndex:rowIndex] objectForKey:@"verb"]];
			[aCell setState:[[[foundTricks objectAtIndex:rowIndex] objectForKey:@"status"] intValue]];
			
		}
    }
}


- (IBAction) search:(id)sender
{
	NSPredicate *predicate;
	NSString *search;
	
	if (tricks) {
		search = [searchField stringValue];
		if (foundTricks)
			[foundTricks release];
		if ([search isEqual:@""]) {
			foundTricks = [NSArray arrayWithArray:tricks];
		} else {
			predicate = [NSPredicate predicateWithFormat:@"verb CONTAINS[cd] %@ or title CONTAINS[cd] %@", search, search];
			foundTricks = [tricks filteredArrayUsingPredicate:predicate];
		}
		[foundTricks retain];
		[table reloadData];
	}
}


- (IBAction) toggle:(id)sender
{
	if ([table selectedRow] > -1) {
		if ([[[foundTricks objectAtIndex:[table selectedRow]] objectForKey:@"status"] intValue] == NSOffState) {
			[[foundTricks objectAtIndex:[table selectedRow]] setObject:[NSNumber numberWithInt:NSOnState] forKey:@"status"];
		} else {
			[[foundTricks objectAtIndex:[table selectedRow]] setObject:[NSNumber numberWithInt:NSOffState] forKey:@"status"];
		}
		[table reloadData];
	}
}



#pragma mark -
#pragma mark getters & setters
- (NSString *) winetricks
{
	int i;
	NSString *winetricks;
	
	winetricks = @"";
	if (tricks) {
		for (i = 0; i < [tricks count]; i++) {
			if ([[[tricks objectAtIndex:i] objectForKey:@"status"] intValue] == NSOnState)
				winetricks = [NSString stringWithFormat:@"%@ %@", winetricks, [[tricks objectAtIndex:i] objectForKey:@"verb"]];
		}
	}
	return winetricks;
}
@end
