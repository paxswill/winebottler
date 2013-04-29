//
//  WBWebView.m
//  WBWebViewController
//
//  Created by Mike Kronenberg on 24.05.10.
//  Copyright 2010 Kronenberg Informatik Lösungen. All rights reserved.
//

#import "WBWebViewController.h"



@implementation WBWebViewController
- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{	
	// Only report feedback for the main frame.
	if (frame == [sender mainFrame]) {
		/*
		 NSURL *url = [[[frame provisionalDataSource] request] URL];
		 if (![[url absoluteString] isEqual:@"about:blank"]) {
		 [[bottlerViewPredefinedWebView mainFrame] stopLoading];
		 [[NSWorkspace sharedWorkspace] openURL:url];
		 }
		 */
	}
}



#pragma mark -
#pragma mark WebUIDelegate
- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
	NSMutableArray *menuItems = [NSMutableArray arrayWithCapacity:0];
	return menuItems;
}


- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener
{
	NSURL *url = [request URL];
	
	// predefined
	if ([[url scheme] isEqual:@"winebottlerinstall"]) {
		[listener ignore];
		[bottlerController askForFilename:[url host]];
		
	// prefixes
	} else if ([[url scheme] isEqual:@"winebottlerrunapp"]) {
		[listener ignore];
		[[NSWorkspace sharedWorkspace] launchApplication:[url path]];
	} else if ([[url scheme] isEqual:@"winebottlershowinfinder"]) {
		[listener ignore];
		[[NSWorkspace sharedWorkspace] selectFile:[url path] inFileViewerRootedAtPath:@""];
	} else if ([[url scheme] isEqual:@"winebottlerreset"]) {
		[listener ignore];
		[bottlerController prefixReset:[url path]];
	} else if ([[url scheme] isEqual:@"winebottlerremove"]) {
		[listener ignore];
		[bottlerController prefixDelete:[url path]];
	
	// hide explanations
	} else if ([[url scheme] isEqual:@"winebottlerhide"]) {
		[listener ignore];
		[bottlerController explanationHide:[url host]];

	// open URL
	} else if ([[url scheme] isEqual:@"http"] || [[url scheme] isEqual:@"https"] || [[url scheme] isEqual:@"mailto"]) {
		[listener ignore];
		[[NSWorkspace sharedWorkspace] openURL:url];
		
	} else {
		[listener use];
	}
}
@end
