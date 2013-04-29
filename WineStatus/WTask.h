//
//  WTask.h
//  WineBottler
//
//  Created by Mike Kronenberg on 01.04.09.
//  Copyright 2009 Kronenberg Informatik Lösungen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WSController.h"


@interface WTask : NSObject {
	WSController *controller;

    NSTask *task;
    NSPipe *stdPipe;
    NSPipe *errPipe;
    NSFileHandle *stdHandle;
    NSFileHandle *errHandle;
    NSMutableData *stdData;
    NSMutableData *errData;
	
	NSString *exe;
}
- (id)initWithArguments:(NSArray *)arguments controller:(id)tController;
- (void) readFromStdPipe:(NSNotification *)notification;
- (void) readFromErrPipe:(NSNotification *)notification;

- (NSMutableString *) pathWithWindowsPath:(NSString *)path;

- (NSTask *)task;
- (NSString *)exe;
@end
