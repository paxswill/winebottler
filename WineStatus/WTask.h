/*
 * WTask.h
 * of the 'WineStatus' target in the 'WineBottler' project
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
