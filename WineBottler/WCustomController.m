//
//  WCustomController.m
//  WineBottler
//
//  Created by Mike Kronenberg on 04.10.09.
//  Copyright 2009 Kronenberg Informatik Lösungen. All rights reserved.
//

#import "WCustomController.h"
#import "WBottlerController.h"



@implementation WCustomController
- (void) awakeFromNib
{
	while([prefixes numberOfItems] > 1)
		[prefixes removeItemAtIndex:1];
	[prefixes addItemsWithTitles:[[NSUserDefaults standardUserDefaults] objectForKey:@"knownPrefixes"]];	
//	[winetricksController update:self];
}


- (IBAction) createCustom:(id)sender
{
	[self askForFilename];
}



#pragma mark -
#pragma mark choose Filename
- (void) askForFilename
{
	NSSavePanel *savePanel;
    NSString *silent;
    NSString *template;
    NSString *installerSwitches;
    NSString *exe;
    BOOL selfcontained;
    
    template = nil;
    if ([prefixes indexOfSelectedItem] > 0)
        template = [prefixes titleOfSelectedItem];
    
    exe = @"winefile";
    installerSwitches = [switches stringValue];
    switch ([copyInstall selectedRow]) {
        case 1:
            exe = [NSString stringWithFormat:@"C:\\winebottler\\%@", [[installer stringValue] lastPathComponent]];
            installerSwitches = @"WINEBOTTLERCOPYFILEONLY";
            break;
        case 2:
            exe = [NSString stringWithFormat:@"C:\\winebottler\\%@", [[installer stringValue] lastPathComponent]];
            installerSwitches = @"WINEBOTTLERCOPYFOLDERONLY";
            break;
    }
    
    silent = @"";
    if ([silentInstall state] == NSOnState)
        silent = @"-q";
    
    selfcontained = FALSE;
    if ([selfcontainedInstall state] == NSOnState) {
        selfcontained = TRUE;
    }
    
	savePanel = [NSSavePanel savePanel];
	[savePanel setExtensionHidden:YES];
	[savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"app"]];
	[savePanel setCanCreateDirectories:YES];
    [savePanel beginSheetModalForWindow:[bottlerController bottlerWindow] completionHandler:^(NSInteger returnCode) {
        if (returnCode == NSOKButton) {
            [[[WBottler alloc] initWithScript:nil
                                          URL:[savePanel URL]
                                     template:template
                                 installerURL:[installer stringValue]
                            installerIsZipped:nil
                                installerName:[[installer stringValue] lastPathComponent]
                           installerArguments:installerSwitches
                                   winetricks:[winetricksController winetricks]
                                    overrides:[overriedes stringValue]
                                          exe:exe
                                 exeArguments:[executableArguments stringValue]
                                bundleVersion:[bundleVersion stringValue]
                             bundleIdentifier:[bundleIdentifier stringValue]
                                       silent:silent
                                selfcontained:selfcontained
                                       sender:bottlerController
                                     callback:nil] autorelease];
        }
    }];
}



#pragma mark -
#pragma mark selectInstaller
- (IBAction) selectInstaller:(id)sender
{
	NSOpenPanel *openPanel;
	
	openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:YES];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"exe",@"msi",nil]];
	[openPanel setAllowsMultipleSelection:NO];
    [openPanel beginSheetModalForWindow:[bottlerController bottlerWindow] completionHandler:^(NSInteger returnCode) {
        if (returnCode == NSOKButton) {
            [installer setStringValue:[[openPanel URL] path]];
        }
    }];
}
@end
