/*
 * WBottlerController.h
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
#import "WBController.h"
#import <WebKit/WebKit.h>
#import "WebKit/WebUIDelegate.h"
#import "WebKit/WebPolicyDelegate.h"
#import "INAppStoreWindow.h"
#import <WBottler/WBottler.h>



@interface WBottlerController : NSObject <NSMetadataQueryDelegate,NSWindowDelegate,NSToolbarDelegate> {
	IBOutlet NSPanel *updatePanel;
    IBOutlet NSProgressIndicator *progressIndicator;
    
	IBOutlet INAppStoreWindow *bottlerWindow;
    
	IBOutlet NSView *toolbar;
	IBOutlet NSButton *toolbarButton1;
	IBOutlet NSButton *toolbarButton2;
	IBOutlet NSButton *toolbarButton3;
	
	IBOutlet NSView *bottlerViewRight;
	
	IBOutlet WebView *bottlerViewPrefixes;
	IBOutlet WebView *bottlerViewPredefined;
	IBOutlet NSView *bottlerViewCustom;
	
	// predefined
    NSDictionary *predefinedApps;
	NSString *predefinedTemplate;
	NSArray *predefinedBottles;
	IBOutlet NSSearchField *predefinedSearchField;
	IBOutlet WebView *bottlerViewPredefinedWebView;
	
	// prefix
	NSMetadataQuery *prefixMetadataQuery;
	NSArray *prefixFound;
	IBOutlet NSSearchField *prefixSearchField;
	IBOutlet WebView *bottlerViewPrefixWebView;
	
}
- (NSWindow *) bottlerWindow;

#pragma mark -
#pragma mark navigation
- (IBAction) showPrefixes:(id)sender;
- (IBAction) showPredefinedWeb:(id)sender;
- (IBAction) showCustom:(id)sender;
- (void) killWine:(id)sender;
- (void) explanationHide:(NSString *)tHide;

#pragma mark -
#pragma mark predefined
- (IBAction) predefinedUpdated:(id)sender;
- (IBAction) predefinedSearch:(id)sender;
- (void) askForFilename:(NSString *)filename;

#pragma mark -
#pragma mark prefix
- (IBAction) prefixQuery:(id)sender;
- (void) prefixQueryFinished:(NSNotification*)note;
- (IBAction) prefixSearch:(id)sender;
- (void) prefixDelete:(NSString *)tPath;
- (void) prefixReset:(NSString *)tPath;
- (void) prefixResetAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void) prefixShowInFinder:(NSString *)tPath;
@end
