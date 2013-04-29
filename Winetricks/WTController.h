//
//  WTController.h
//  WineBottler
//
//  Created by Mike Kronenberg on 26.05.10.
//  Copyright 2010 Kronenberg Informatik Lösungen. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#import <WBottler/WWinetricksController.h>
#import <KBActionWindow/KBActionWindow.h>
#import <KBActionWindow/KBAction.h>


@interface WTController : NSObject <NSWindowDelegate> {
	IBOutlet NSWindow *winetricksWindow;	
	IBOutlet WWinetricksController *winetricksController;
	
	KBAction *copyAction;
	int filesToCopy;
	int filesCopied;
	NSFileHandle *fileHandle;
	NSMutableArray *runningExes;
}
- (void) copyPrefixFromPath:(NSString *)fromPath toPath:(NSString *)toPath withTitle:(NSString *)tTitle;
- (IBAction) abort:(id)sender;
@end
