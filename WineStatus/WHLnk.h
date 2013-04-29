/*
 *  WHLnk.h
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

#import <Cocoa/Cocoa.h>


#define SCF_PIDL 1
#define SCF_LOCATION 2
#define SCF_DESCRIPTION 4
#define SCF_RELATIVE 8
#define SCF_WORKDIR 0x10
#define SCF_ARGS 0x20
#define SCF_CUSTOMICON 0x40
#define SCF_UNICODE 0x80
#define SCF_PRODUCT 0x800
#define SCF_COMPONENT 0x1000


typedef unsigned long   DWORD;
typedef unsigned short  WORD;

typedef struct _GUID {
    unsigned long  Data1;
    unsigned short Data2;
    unsigned short Data3;
    unsigned char  Data4[ 8 ];
} GUID;

typedef struct _FILETIME {
    DWORD dwLowDateTime;
    DWORD dwHighDateTime;
} FILETIME, *PFILETIME, *LPFILETIME;

typedef struct _LINK_HEADER {
	DWORD    dwSize;        /* 0x00 size of the header - 0x4c */
	GUID     MagicGuid;     /* 0x04 is CLSID_ShellLink */
	DWORD    dwFlags;       /* 0x14 describes elements following */
	DWORD    dwFileAttr;    /* 0x18 attributes of the target file */
	FILETIME Time1;         /* 0x1c */
	FILETIME Time2;         /* 0x24 */
	FILETIME Time3;         /* 0x2c */
	DWORD    dwFileLength;  /* 0x34 File length */
	DWORD    nIcon;         /* 0x38 icon number */
	DWORD   fStartup;       /* 0x3c startup type */
	DWORD   wHotKey;        /* 0x40 hotkey */
	DWORD   Unknown5;       /* 0x44 */
	DWORD   Unknown6;       /* 0x48 */
} LINK_HEADER, * PLINK_HEADER;

typedef struct _LOCATION_INFO {
	DWORD  dwTotalSize;
	DWORD  dwHeaderSize;
	DWORD  dwFlags;
	DWORD  dwVolTableOfs;
	DWORD  dwLocalPathOfs;
	DWORD  dwNetworkVolTableOfs;
	DWORD  dwFinalPathOfs;
} LOCATION_INFO;


@interface WHLnk : NSObject {
	NSString *localPath;
	NSString *finalPath;
	
	NSString *description;
	NSString *workingDirectory;
	NSString *relativePath;
	NSString *iconPath;
	NSArray *arguments;
	
	unsigned long flags;
}

- (id) initWithLnk:(NSString*)lnkPath;
- (void) readFromLnkFile:(NSString *)lnkPath;
- (NSData*) getDataPIDL:(NSData *)lnkData location:(unsigned int *)lnkDataLoc;
- (NSData*) getData:(NSData *)lnkData location:(unsigned int *)lnkDataLoc;
- (NSString*) getString:(NSData *)lnkData location:(unsigned int *)lnkDataLoc;
- (int) flags;
- (void) setFlags:(NSData*)data;
- (NSString *) localPath;
- (NSString *) finalPath;
- (void) setLocationInfo:(NSData*)data;
- (NSString *) description;
- (void) setDescription:(NSString*)string;
- (NSString *) relativePath;
- (void) setRelativePath:(NSString*)string;
- (NSString *) workingDirectory;
- (void) setWorkingDirectory:(NSString*)string;
- (NSArray *) arguments;
- (void) setArguments:(NSString*)string;
- (NSString *) iconPath;
- (void) setIconPath:(NSString*)string;

@end