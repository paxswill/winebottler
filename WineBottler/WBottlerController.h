//
//  WBottlerController.h
//  WineBottler
//
//  Created by Mike Kronenberg on 23.04.09.
//  Copyright 2009 Kronenberg Informatik Lösungen. All rights reserved.
//

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
//- (void) changePrefixTo:(NSString *)tPrefix;
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
