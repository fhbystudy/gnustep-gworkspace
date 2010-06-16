/* ContentViewersProtocol.h
 *  
 * Copyright (C) 2004 Free Software Foundation, Inc.
 *
 * Author: Enrico Sersale <enrico@imago.ro>
 * Date: January 2004
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

@protocol ContentViewersProtocol

- (id)initWithFrame:(NSRect)frameRect
          inspector:(id)insp;

- (void)displayPath:(NSString *)path;

- (void)displayLastPath:(BOOL)forced;

- (void)displayData:(NSData *)data 
             ofType:(NSString *)type;

- (NSString *)currentPath;

- (void)stopTasks;

- (BOOL)canDisplayPath:(NSString *)path;

- (BOOL)canDisplayDataOfType:(NSString *)type;

- (NSString *)winname;

- (NSString *)description;

@end 


