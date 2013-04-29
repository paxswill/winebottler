//
//  WBWebViewController.h
//  WineBottler
//
//  Created by Mike Kronenberg on 24.05.10.
//  Copyright 2010 Kronenberg Informatik Lösungen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <WebKit/WebKit.h>
#import "WebKit/WebUIDelegate.h"
#import "WebKit/WebPolicyDelegate.h"

#import "WBottlerController.h"


@interface WBWebViewController : NSObject {
	IBOutlet id bottlerController;
}

#pragma mark -
#pragma mark Predefined
@end
