//
//  CustomTextView.m
//  EmailBodyTemplateNew
//
//  Created by pavan on 4/16/13.
//  Copyright (c) 2013 pavan. All rights reserved.
//

#import "CustomTextView.h"
#import <CoreText/CoreText.h>

#import <QuartzCore/QuartzCore.h>

#define fontSize  20

@implementation CustomTextView
@synthesize rangesArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        rangesArray  = [[NSMutableArray alloc] init];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //Create a mutable attribute string
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    
    //move the self.text into attrString
    CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), (CFStringRef)self.text);
    
    
    CTFontRef sysUIFont = CTFontCreateWithName(( CFStringRef)self.font.fontName, fontSize, NULL);
    
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, self.text.length), kCTFontAttributeName, sysUIFont);
    
    /// ===============================
    
    // check for text length
    if ([self.text length] > 0) {
        for (int i = 0; i < [rangesArray count]; i++) {
            
            // Get the NSRange added in array
            NSRange addedRange = [[rangesArray objectAtIndex:i] rangeValue];
            
            // Get the string at added NSRange
            NSString * strAtAddedRange = [self.text substringWithRange:addedRange];
            
            // Find the sting at Added NSRange
            
            // Create the rect for the added string
//            [self createBackGroundViewForString:strAtAddedRange ForRange:addedRange OriginalStr:attrString];
            
            // Create a CFRange ref for added range
            CFRange stringRange = CFRangeMake(addedRange.location, addedRange.length);
            
            // Set the property for different Font for added NSRange
            CFAttributedStringSetAttribute(attrString, stringRange, kCTFontAttributeName, sysUIFont);
            
            //Add own color for the text if needed
            //Set the color for string at added NSRange
            CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
            CGFloat components[] = { 1.0, 0.3, 0.3, 0.8 };
            CGColorRef red = CGColorCreate(rgbColorSpace, components);
            CGColorSpaceRelease(rgbColorSpace);
            CFAttributedStringSetAttribute(attrString, stringRange,
                                           kCTForegroundColorAttributeName, red);
            CFRelease(red);
        }
        /// ===============================
        
        
        // now for the actual drawing
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // flip the coordinate system
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, self.bounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        
        //Create path for the text
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGRect fr = self.bounds;
        fr.origin.x = 9;
        fr.size.width -= 19.0f;
        fr.origin.y = -10;
        
        CGPathAddRect(path, NULL, fr);
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                                                    CFRangeMake(0, 0), path, NULL);
        CFRelease(framesetter);
        CFRelease(path);
        CTFrameDraw(frame, context);
    }
}

- (void)createBackGroundViewForString:(NSString *)subString ForRange:(NSRange)subStringRange OriginalStr:(CFMutableAttributedStringRef)originalAttributedString
{
    // Create a path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, [self bounds]);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)originalAttributedString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, CFAttributedStringGetLength(originalAttributedString)), path, NULL);
    
    // Get the lines in text
    CFArrayRef lines = CTFrameGetLines(frame);
    
    // Get lines count
    int lineCount = CFArrayGetCount(lines);
    
    // Create a frame which holds for added string
    CGRect textFrame = CGRectZero;
    
    
    if (lineCount > 0) {
        for (int i = 0; i < lineCount; i++) {
            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
            
            CGPoint origins;
            CTFrameGetLineOrigins(frame, CFRangeMake(i, 1), &origins);
            
            CGFloat ascent, descent;
            CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
            
            textFrame.origin.y = self.bounds.origin.y + self.bounds.size.height - (origins.y + ascent);
            
            CFArrayRef runs = CTLineGetGlyphRuns(line);
            CFIndex runsTotal = CFArrayGetCount(runs);
            
            if (runsTotal > 0) {
                for (int j = 0; j < runsTotal; j++) {
                    CTRunRef run = CFArrayGetValueAtIndex(runs, j);
                    NSRange range = NSMakeRange(CTRunGetStringRange(run).location, CTRunGetStringRange(run).length);
                    if (range.length > 0 && range.length != NSIntegerMax && range.location < CFAttributedStringGetLength(originalAttributedString)) {
                        NSString *string1 = [self.text substringWithRange:range];
                        
                        const CGPoint *org = CTRunGetPositionsPtr(run);
                        textFrame.origin.x = org->x;
                        
                        CTFontRef font = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
                        NSString *runFontName = ( NSString *)CTFontCopyPostScriptName(font);
                        textFrame.size = [subString sizeWithFont:[UIFont fontWithName:runFontName size:fontSize] constrainedToSize:self.frame.size lineBreakMode:NSLineBreakByWordWrapping];
                        
                        // Check if a string is available in this line or no
                        if (subStringRange.location > range.location && subStringRange.location < (range.location + range.length)) {
                            NSString * strasdf = [string1 substringToIndex:subStringRange.location - range.location];
                            
                            
                            CGFloat xcoor = [strasdf sizeWithFont:[UIFont fontWithName:runFontName size:fontSize] constrainedToSize:self.frame.size lineBreakMode:NSLineBreakByWordWrapping].width + textFrame.origin.x;
                            
                            textFrame.origin.x = xcoor + 8;
                            textFrame.size.height -= 3.0;
                            textFrame.origin.y += 9.0f;
                            
                            // Temp fill with blue colour
                            [[UIColor blueColor] setFill];
                            UIRectFill( textFrame );
                        }
                    }
                }
            }
        }
    }
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}
@end
