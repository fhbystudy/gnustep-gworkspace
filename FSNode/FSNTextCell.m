/* FSNTextCell.m
 *  
 * Copyright (C) 2004-2012 Free Software Foundation, Inc.
 *
 * Author: Enrico Sersale <enrico@imago.ro>
 * Date: March 2004
 *
 * This file is part of the GNUstep FSNode framework
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
#import <AppKit/AppKit.h>
#import "FSNTextCell.h"

static SEL cutNameSel = NULL;
static cutIMP cutName = NULL;

static SEL cutDateSel = NULL;
static cutIMP cutDate = NULL;


@implementation FSNTextCell

+ (void)initialize
{
  static BOOL initialized = NO;

  if (initialized == NO) {
    cutNameSel = @selector(cutTitle:toFitWidth:);
    cutName = (cutIMP)[self instanceMethodForSelector: cutNameSel];    
    cutDateSel = @selector(cutTitle:toFitWidth:);
    cutDate = (cutIMP)[self instanceMethodForSelector: cutDateSel];    

    initialized = YES;
  }
}

- (void)dealloc
{
  RELEASE (uncuttedTitle);
  RELEASE (fontAttr);
  RELEASE (dots);
  RELEASE (icon);  
  [super dealloc];
}

- (id)init
{
  self = [super init];

  if (self) {
    ASSIGN (fontAttr, [NSDictionary dictionaryWithObject: [self font] 
                                                  forKey: NSFontAttributeName]);
    ASSIGN (dots, @"...");
    dtslenght = [dots sizeWithAttributes: fontAttr].width; 
    titlesize = NSMakeSize(0, 0);
    icon = nil;
    dateCell = NO;
    cutTitleSel = cutNameSel;
    cutTitle = cutName;    
  }

  return self;
}

- (id)copyWithZone:(NSZone *)zone
{
  FSNTextCell *c = [super copyWithZone: zone];

  c->fontAttr = [fontAttr copyWithZone: zone];
  c->dots = [dots copyWithZone: zone];

  c->dtslenght = dtslenght;
  c->dateCell = dateCell;
  
  if (uncuttedTitle) {
    c->uncuttedTitle = [uncuttedTitle copyWithZone: zone];
  } else {
    c->uncuttedTitle = nil;
  }
  
  c->cutTitleSel = cutNameSel;
  c->cutTitle = cutName;   

  RETAIN (icon);

  return c;
}

- (void)setStringValue:(NSString *)aString
{
  [super setStringValue: aString];
  titlesize = [[self stringValue] sizeWithAttributes: fontAttr]; 
}

- (void)setFont:(NSFont *)fontObj
{
  [super setFont: fontObj];
  ASSIGN (fontAttr, [NSDictionary dictionaryWithObject: [self font] 
                                                forKey: NSFontAttributeName]);
  titlesize = [[self stringValue] sizeWithAttributes: fontAttr]; 
  dtslenght = [dots sizeWithAttributes: fontAttr].width;     
}

- (void)setIcon:(NSImage *)icn
{ 
  ASSIGN (icon, icn);
}

- (NSImage *)icon
{
  return icon;
}

- (float)uncuttedTitleLenght
{
  return titlesize.width;
}

- (void)setDateCell:(BOOL)value
{
  dateCell = value;

  if (dateCell) {
    cutTitleSel = cutDateSel;
    cutTitle = cutDate; 
  } else {
    cutTitleSel = cutNameSel;
    cutTitle = cutName;  
  }
}

- (BOOL)isDateCell
{
  return dateCell;
}

- (NSString *)cutTitle:(NSString *)title 
            toFitWidth:(float)width
{
  if ([title sizeWithAttributes: fontAttr].width > width) {
    int tl = [title length];
  
    if (tl <= 5) {
      return dots;
    } else {
      int fpto = (tl / 2) - 2;
      int spfr = fpto + 3;
      NSString *fp = [title substringToIndex: fpto];
      NSString *sp = [title substringFromIndex: spfr];
      NSString *dotted = [NSString stringWithFormat: @"%@%@%@", fp, dots, sp];
      int dl = [dotted length];
      float dotl = [dotted sizeWithAttributes: fontAttr].width;
      int p = 0;

      while (dotl > width) {
        if (dl <= 5) {
          return dots;
        }        

        if (p) {
          fpto--;
        } else {
          spfr++;
        }
        p = !p;

        fp = [title substringToIndex: fpto];
        sp = [title substringFromIndex: spfr];
        dotted = [NSString stringWithFormat: @"%@%@%@", fp, dots, sp];
        dotl = [dotted sizeWithAttributes: fontAttr].width;
        dl = [dotted length];
      }      
      
      return dotted;
    }
  }
  
  return title;
}

- (NSString *)cutDateTitle:(NSString *)title 
                toFitWidth:(float)width
{
  if ([title sizeWithAttributes: fontAttr].width > width) {
    int tl = [title length];
    
    if (tl <= 5) {
      return dots;
    } else {
      NSString *format = @"%b %d %Y";
      NSCalendarDate *date = [NSCalendarDate dateWithString: title
                                             calendarFormat: format];
      if (date) {
        NSString *descr;
        
        format = @"%m/%d/%y";
        descr = [date descriptionWithCalendarFormat: format 
                            timeZone: [NSTimeZone localTimeZone] locale: nil];
        
        if ([descr sizeWithAttributes: fontAttr].width > width) {
          return [self cutTitle: descr toFitWidth: width];
        } else {
          return descr;
        }
        
      } else {
        return [self cutTitle: title toFitWidth: width];
      }
    }
  }
  
  return title;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame 
		                   inView:(NSView *)controlView
{
  NSRect title_rect = cellFrame;
  float textlenght = title_rect.size.width;
  NSString *cuttitle;  

#define MARGIN (2.0)
 
  if (icon) {
    textlenght -= ([icon size].width + (MARGIN * 2));
  }
  
  textlenght -= MARGIN;
  ASSIGN (uncuttedTitle, [self stringValue]);
  cuttitle = (*cutTitle)(self, cutTitleSel, uncuttedTitle, textlenght);
  [self setStringValue: cuttitle];        

  title_rect.size.height = titlesize.height;
  title_rect.origin.y += ((cellFrame.size.height - titlesize.height) / 2.0);

  if (icon == nil) {
    [super drawInteriorWithFrame: title_rect inView: controlView];
    
  } else {
    NSRect icon_rect;    

    icon_rect.origin = cellFrame.origin;
    icon_rect.size = [icon size];
    icon_rect.origin.x += MARGIN;
    icon_rect.origin.y += ((cellFrame.size.height - icon_rect.size.height) / 2.0);
    if ([controlView isFlipped]) {
	    icon_rect.origin.y += icon_rect.size.height;
    }

    title_rect.origin.x += (icon_rect.size.width + (MARGIN * 2));	
    title_rect.size.width -= (icon_rect.size.width + (MARGIN * 2));	
    title_rect = NSIntegralRect(title_rect);  
    
    [super drawInteriorWithFrame: title_rect inView: controlView];

    [icon compositeToPoint: icon_rect.origin 
	               operation: NSCompositeSourceOver];
  }
  
  [self setStringValue: uncuttedTitle];          
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{
  return NO;
}

@end
