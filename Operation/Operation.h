/* Operation.h
 *  
 * Copyright (C) 2004-2010 Free Software Foundation, Inc.
 *
 * Author: Enrico Sersale <enrico@imago.ro>
 * Date: March 2004
 *
 * This file is part of the GNUstep GWorkspace application
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02111 USA.
 */

#import <Foundation/Foundation.h>

@class FileOpInfo;

enum {
  MOVE,
  RENAME,
  DESTROY,
  COPY,
  CREATE
};

@interface Operation : NSObject 
{
  NSMutableArray *fileOperations;
  int fopRef;
  
  BOOL filenamesCutted;
    
  NSFileManager *fm;  
  NSNotificationCenter *nc; 
}

- (void)setFilenamesCutted:(BOOL)value;

- (BOOL)filenamesWasCutted;

- (void)performOperation:(NSDictionary *)opdict;

- (BOOL)isLockedAction:(int)action
                onPath:(NSString *)path;

- (BOOL)isLockedByOperation:(FileOpInfo *)opinfo
                     action:(int)action
                     onPath:(NSString *)path;
                     
- (void)endOfFileOperation:(FileOpInfo *)op;

- (int)fileOpRef;

- (FileOpInfo *)fileOpWithRef:(int)ref;

- (NSRect)rectForFileOpWindow;

- (BOOL)verifyFileAtPath:(NSString *)path
            forOperation:(NSString *)operation;

- (BOOL)ascendentOfPath:(NSString *)path 
                inPaths:(NSArray *)paths;

- (BOOL)descendentOfPath:(NSString *)path 
                 inPaths:(NSArray *)paths;

- (BOOL)operationsPending;

@end

