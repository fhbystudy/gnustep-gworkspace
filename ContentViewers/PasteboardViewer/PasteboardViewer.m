/* PasteboardViewer.m
 *  
 * Copyright (C) 2003 Free Software Foundation, Inc.
 *
 * Author: Enrico Sersale <enrico@imago.ro>
 * Date: Octomber 2003
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
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */


#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
  #ifdef GNUSTEP 
#include "GWProtocol.h"  
#include "InspectorsProtocol.h"
#include "GWLib.h"
  #else
#include <GWorkspace/GWProtocol.h>  
#include <GWorkspace/InspectorsProtocol.h>
#include <GWorkspace/GWLib.h>
  #endif
#include "PasteboardViewer.h"
#include "GNUstep.h"
#include <math.h>

@implementation PasteboardViewer

- (void)dealloc
{
  RELEASE (RTFViewer);
  RELEASE (TIFFViewer);
  RELEASE (label);
  
  [super dealloc];
}

- (id)initInPanel:(id)apanel withFrame:(NSRect)frame index:(int)idx
{
  self = [super init];
  
  if(self) {
    NSRect rect;
  
    [self setFrame: frame];
    panel = (id<InspectorsProtocol>)apanel;
    index = idx;

    rect = [self bounds];
    
    RTFViewer = [[NSRTFPboardViewer alloc] initWithFrame: rect];
    TIFFViewer = [[NSTIFFPboardViewer alloc] initWithFrame: rect];
    currentViewer = nil;    
    
    //label if error
    label = [[NSTextField alloc] initWithFrame: NSMakeRect(2, 133, 255, 25)];	
    [label setFont: [NSFont systemFontOfSize: 18]];
    [label setAlignment: NSCenterTextAlignment];
    [label setBackgroundColor: [NSColor windowBackgroundColor]];
    [label setTextColor: [NSColor grayColor]];	
    [label setBezeled: NO];
    [label setEditable: NO];
    [label setSelectable: NO];
    [label setStringValue: @"Invalid Contents"];
  }
	
	return self;
}

- (void)setBundlePath:(NSString *)path
{
  ASSIGN (bundlePath, path);
}

- (NSString *)bundlePath
{
  return bundlePath;
}

- (void)setIndex:(int)idx
{
  index = idx;
}

- (void)activateForPath:(NSString *)path
{
}

- (BOOL)displayData:(NSData *)data ofType:(NSString *)type
{
  buttOk = [panel okButton];
  if (buttOk) {
    [buttOk setEnabled: NO];			
  }
  
  if (currentViewer && [currentViewer superview]) {
    [currentViewer removeFromSuperview];
  }
  if ([label superview]) {
    [label removeFromSuperview];
  }
  
  if ([type isEqual: NSStringPboardType] ||
                [type isEqual: NSRTFPboardType] ||
                [type isEqual: NSRTFDPboardType]) {
    currentViewer = RTFViewer;
  } else if ([type isEqual: NSTIFFPboardType]) {
    currentViewer = TIFFViewer;
  } else {
    currentViewer = nil;
  }
  
  if (currentViewer) {
    [self addSubview: currentViewer]; 
    
    if ([currentViewer displayData: data ofType: type] == NO) {
      [currentViewer removeFromSuperview];
      [self addSubview: label]; 
    } else {
      return YES;
    }
    
  } else {
    [self addSubview: label]; 
  }  
  
  return NO;
}

- (BOOL)stopTasks
{
  return YES;
}

- (void)deactivate
{
  [self removeFromSuperview];
}

- (BOOL)canDisplayFileAtPath:(NSString *)path
{
	return NO;
}

- (BOOL)canDisplayData:(NSData *)data ofType:(NSString *)type
{
  if ([type isEqual: NSTIFFPboardType] 
            || [type isEqual: NSRTFPboardType]
            || [type isEqual: NSRTFDPboardType]
            || [type isEqual: NSStringPboardType]) {
    return YES;
  }
  
  return NO;
}

- (int)index
{
	return index;
}

- (NSString *)winname
{
	return NSLocalizedString(@"Pasteboard Inspector", @"");	
}

@end

@implementation NSRTFPboardViewer

- (void)dealloc
{
  RELEASE (scrollView);
  RELEASE (textView);
  [super dealloc];
}

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame: frame];
  
  if(self) {
    NSRect rect;
    
    [self setFrame: frame];
        
    rect = NSMakeRect(0, 10, 257, 215);
    scrollView = [[NSScrollView alloc] initWithFrame: rect];
    [scrollView setBorderType: NSBezelBorder];
    [scrollView setHasHorizontalScroller: NO];
    [scrollView setHasVerticalScroller: YES]; 
    [scrollView setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];
    [[scrollView contentView] setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];
    [[scrollView contentView] setAutoresizesSubviews:YES];
    [self addSubview: scrollView]; 

    rect = [[scrollView contentView] frame];
    textView = [[NSTextView alloc] initWithFrame: rect];
    [textView setBackgroundColor: [NSColor whiteColor]];
    [textView setRichText: YES];
    [textView setEditable: NO];
    [textView setSelectable: NO];
    [textView setHorizontallyResizable: NO];
    [textView setVerticallyResizable: YES];
    [textView setMinSize: NSMakeSize (0, 0)];
    [textView setMaxSize: NSMakeSize (1E7, 1E7)];
    [textView setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];
    [[textView textContainer] setContainerSize: NSMakeSize (rect.size.width, 1e7)];
    [[textView textContainer] setWidthTracksTextView: YES];
    [textView setUsesRuler: NO];
    [scrollView setDocumentView: textView];
  }
	
	return self;
}

- (BOOL)displayData:(NSData *)data ofType:(NSString *)type
{
  NSAttributedString *attrstr = nil;
  NSFont *font = nil;  

  if ([type isEqual: NSRTFPboardType]) {    
    attrstr = [[NSAttributedString alloc] initWithRTF: data
						                       documentAttributes: NULL];
    AUTORELEASE (attrstr);
  } else if ([type isEqual: NSRTFDPboardType]) { 
    attrstr = [[NSAttributedString alloc] initWithRTFD: data
						                        documentAttributes: NULL];
    AUTORELEASE (attrstr);
  } else if ([type isEqual: NSStringPboardType]) { 
    NSString *str = [[NSString alloc] initWithData: data
                           encoding: [NSString defaultCStringEncoding]];
    
    if (str) {
      attrstr = [[NSAttributedString alloc] initWithString: str];
      RELEASE (str);
      AUTORELEASE (attrstr);
    }
  }

  if (attrstr) {
    [[textView textStorage] setAttributedString: attrstr];
    font = [NSFont systemFontOfSize: 8.0];
		[[textView textStorage] addAttribute: NSFontAttributeName 
                                   value: font 
                                   range: NSMakeRange(0, [attrstr length])];
    return YES;
  } 

  return NO;
}

@end


@implementation NSTIFFPboardViewer

- (void)dealloc
{
  TEST_RELEASE (imview);
  TEST_RELEASE (widthResult);
  TEST_RELEASE (heightResult);
  [super dealloc];
}

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame: frame];
  
  if(self) {
    NSTextField *widthLabel, *heightLabel;

    [self setFrame: frame];
    
    imrect = NSMakeRect(0, 30, 257, 215);
    imview = [[NSImageView alloc] initWithFrame: imrect];
    [imview setImageFrameStyle: NSImageFrameGrayBezel];
    [imview setImageAlignment: NSImageAlignCenter];
    [self addSubview: imview]; 
    
    widthLabel = [[NSTextField alloc] initWithFrame: NSMakeRect(5,2,40, 20)];	
    [widthLabel setAlignment: NSRightTextAlignment];
    [widthLabel setBackgroundColor: [NSColor windowBackgroundColor]];
    [widthLabel setBezeled: NO];
    [widthLabel setEditable: NO];
    [widthLabel setSelectable: NO];
    [widthLabel setStringValue: @"Width :"];
    [self addSubview: widthLabel]; 
    RELEASE (widthLabel);

    widthResult = [[NSTextField alloc] initWithFrame: NSMakeRect(45,2,40, 20)];	
    [widthResult setAlignment: NSRightTextAlignment];
    [widthResult setBackgroundColor: [NSColor windowBackgroundColor]];
    [widthResult setBezeled: NO];
    [widthResult setEditable: NO];
    [widthResult setSelectable: NO];
    [widthResult setStringValue: @""];
    [self addSubview: widthResult]; 

    heightLabel = [[NSTextField alloc] initWithFrame: NSMakeRect(160,2,40, 20)];	
    [heightLabel setAlignment: NSRightTextAlignment];
    [heightLabel setBackgroundColor: [NSColor windowBackgroundColor]];
    [heightLabel setBezeled: NO];
    [heightLabel setEditable: NO];
    [heightLabel setSelectable: NO];
    [heightLabel setStringValue: @"Height :"];
    [self addSubview: heightLabel]; 
    RELEASE (heightLabel);

    heightResult = [[NSTextField alloc] initWithFrame: NSMakeRect(200,2,40, 20)];	
    [heightResult setAlignment: NSRightTextAlignment];
    [heightResult setBackgroundColor: [NSColor windowBackgroundColor]];
    [heightResult setBezeled: NO];
    [heightResult setEditable: NO];
    [heightResult setSelectable: NO];
    [heightResult setStringValue: @""];
    [self addSubview: heightResult];
  }
	
	return self;
}

- (BOOL)displayData:(NSData *)data ofType:(NSString *)type
{
  NSImage *image = [[NSImage alloc] initWithData: data];

  if (image != nil) {
    NSSize is = [image size];
    NSSize rs = imrect.size;
    NSSize size;

    if ((is.width <= rs.width) && (is.height <= rs.height)) {
      [imview setImageScaling: NSScaleNone];
    } 
    else {
      [imview setImageScaling: NSScaleProportionally];
    }

    [imview setImage: image];
    size = [image size];
    [widthResult setStringValue: [[NSNumber numberWithInt: size.width] stringValue]];
    [heightResult setStringValue: [[NSNumber numberWithInt: size.height] stringValue]];

    RELEASE (image);
    return YES;    	
  }
  
  return NO;
}

@end


