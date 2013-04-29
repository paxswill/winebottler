/*
 *  WHLnk.m
 *  WineHelper
 *
 *  Created by William Knop on 7/6/06.
 *  Copyright 2006 Darwine Team. All rights reserved.
 *
 *  darwine.sf.net
 *  www.winehq.com
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#import "WHLnk.h"


@implementation WHLnk


- (id) init
{
    self = [super init];
	localPath =			[[NSString alloc] init];
	finalPath =			[[NSString alloc] init];
	description =		[[NSString alloc] init];
	workingDirectory =	[[NSString alloc] init];
	relativePath =		[[NSString alloc] init];
	iconPath =			[[NSString alloc] init];
	arguments =			[[NSArray alloc] init];
	flags =				0;
	
    return self;
}

- (id) initWithLnk:(NSString*)lnkPath
{
	self = [self init];
	[self readFromLnkFile:lnkPath];
	
	return self;
}

- (void) readFromLnkFile:(NSString *)lnkPath
{
	/* TODO: convert windows path to posix path? */
	NSData *lnkData = [NSData dataWithContentsOfFile:lnkPath];
	
	// get the link header
	unsigned int lnkDataLoc = 0;
	[self setFlags:[self getData:lnkData location:&lnkDataLoc]];
	if (flags & SCF_PIDL) { [self getDataPIDL:lnkData location:&lnkDataLoc]; }
	if (flags & SCF_LOCATION) { [self setLocationInfo:[self getData:lnkData location:&lnkDataLoc]]; }
    if (flags & SCF_DESCRIPTION) { [self setDescription:[self getString:lnkData location:&lnkDataLoc]]; }
    if (flags & SCF_RELATIVE) { [self setRelativePath:[self getString:lnkData location:&lnkDataLoc]]; }
    if (flags & SCF_WORKDIR) { [self setWorkingDirectory:[self getString:lnkData location:&lnkDataLoc]]; }
    if (flags & SCF_ARGS) { [self setArguments:[self getString:lnkData location:&lnkDataLoc]]; }
    if (flags & SCF_CUSTOMICON) { [self setIconPath:[self getString:lnkData location:&lnkDataLoc]]; }
    if (flags & SCF_PRODUCT) { /* UNIMPLEMENTED */ }
    if (flags & SCF_COMPONENT) { /* UNIMPLEMENTED */ }
}


- (NSData*) getDataPIDL:(NSData *)lnkData location:(unsigned int *)lnkDataLoc
{
	unsigned short dataSize = 0;
	[lnkData getBytes:&dataSize range:(NSRange){*lnkDataLoc, sizeof(dataSize)}];
	dataSize = NSSwapLittleShortToHost(dataSize);
	
	NSData *data = [lnkData subdataWithRange:(NSRange){*lnkDataLoc, sizeof(dataSize) + dataSize}];
	
	*lnkDataLoc += sizeof(dataSize) + dataSize;
	return data;
}


- (NSData*) getData:(NSData *)lnkData location:(unsigned int *)lnkDataLoc
{
	unsigned int dataSize = 0;
	[lnkData getBytes:&dataSize range:(NSRange){*lnkDataLoc, sizeof(dataSize)}];
	dataSize = NSSwapLittleShortToHost(dataSize);
	
	NSData *data = [lnkData subdataWithRange:(NSRange){*lnkDataLoc, dataSize}];
	
	*lnkDataLoc += dataSize;
	return data;
}


- (NSString*) getString:(NSData *)lnkData location:(unsigned int *)lnkDataLoc
{
	unsigned short stringSize;
	[lnkData getBytes:&stringSize range:(NSRange){*lnkDataLoc, sizeof(stringSize)}];
	stringSize = NSSwapLittleShortToHost(stringSize);
	*lnkDataLoc += sizeof(stringSize);
	
	NSData *stringData;
	NSString *string;
	
	if (flags & SCF_UNICODE) {
		stringData = [lnkData subdataWithRange:(NSRange){*lnkDataLoc, stringSize*sizeof(WORD)}];
		string = [[[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding] autorelease];
		*lnkDataLoc += stringSize*sizeof(WORD);
	} else {
		stringData = [lnkData subdataWithRange:(NSRange){*lnkDataLoc, stringSize}];
		string = [[[NSString alloc] initWithData:stringData encoding:NSASCIIStringEncoding] autorelease];
		*lnkDataLoc += stringSize;
	}
	
	return string;
}


- (int) flags
{
	return flags;
}


- (void) setFlags:(NSData*)data
{
	LINK_HEADER *hdr = (LINK_HEADER *)[data bytes];
	flags = NSSwapLittleLongToHost(hdr->dwFlags);
}


- (NSString *) localPath
{
	return [[localPath retain] autorelease];
}


- (NSString *) finalPath
{
	return [[finalPath retain] autorelease];
}


- (void) setLocationInfo:(NSData*)data
{
	LOCATION_INFO *info = (LOCATION_INFO *)[data bytes];
	DWORD localPathOfs = NSSwapLittleLongToHost(info->dwLocalPathOfs);
	DWORD finalPathOfs = NSSwapLittleLongToHost(info->dwFinalPathOfs);
	
	[localPath release];
	[finalPath release];
	
	localPath = [[NSString alloc] initWithCString:(((char *)[data bytes]) + localPathOfs) encoding:NSASCIIStringEncoding];
	finalPath = [[NSString alloc] initWithCString:(((char *)[data bytes]) + finalPathOfs) encoding:NSASCIIStringEncoding];
}


- (NSString *) description
{
	return [[description retain] autorelease];
}


- (void) setDescription:(NSString*)string
{
	[description release];
	description = [string copy];
}


- (NSString *) relativePath
{
	return [[relativePath retain] autorelease];
}


- (void) setRelativePath:(NSString*)string
{
	[relativePath release];
	relativePath = [string copy];
}


- (NSString *) workingDirectory
{
	return [[workingDirectory retain] autorelease];
}


- (void) setWorkingDirectory:(NSString*)string
{
	[workingDirectory release];
	workingDirectory = [string copy];
}


- (NSArray *) arguments
{
	return [[arguments retain] autorelease];
}


- (void) setArguments:(NSString*)string
{
	[arguments release];
	arguments = [string componentsSeparatedByString:@" "];
}


- (NSString *) iconPath
{
	return [[iconPath retain] autorelease];
}


- (void) setIconPath:(NSString*)string
{
	[iconPath release];
	iconPath = [string copy];
}


@end