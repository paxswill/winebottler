/*
 * WBWebViewController.m
 * of the 'WineBottler' target in the 'WineBottler' project
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



#import "WBWebViewController.h"



@implementation WBWebViewController
- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{	

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
