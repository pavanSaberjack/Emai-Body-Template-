//
//  ViewController.m
//  EmailBodyTemplateNew
//
//  Created by pavan on 4/15/13.
//  Copyright (c) 2013 pavan. All rights reserved.
//

#import "ViewController.h"
#import "CustomTextView.h"

int value = 0;

@interface ViewController ()<UITextViewDelegate>
{
    CustomTextView * txtView;
    
    NSMutableArray *objArray;
    NSMutableArray *rangeArray;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    rangeArray = [[NSMutableArray alloc] init];
    
    objArray = [[NSMutableArray alloc] init];
    [objArray addObject:@"hi"];
    [objArray addObject:@"hello"];
    [objArray addObject:@"abc"];
    
    txtView = [[CustomTextView alloc] initWithFrame:CGRectMake(10, 10, 200, 200)];
    [txtView setDelegate:self];
    [txtView setTextColor:[UIColor clearColor]];
    [txtView setAutocorrectionType:UITextAutocorrectionTypeNo];
    [txtView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [txtView setFont:[UIFont fontWithName:@"Helvetica" size:20.0f]];
    [txtView setText:@""];
    [self.view addSubview:txtView];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(250, 30, 40, 40)];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - textview delegate methods
- (void)textViewDidChange:(UITextView *)textView
{
//    [txtView setText:[NSString stringWithFormat:@"%@",textView.text]];
    
    [txtView setNeedsDisplay];
    
    //    CGSize textSize = [textView.text sizeWithFont:bodyLabel.font constrainedToSize:textView.frame.size lineBreakMode:NSLineBreakByCharWrapping];
    //
    //    CGRect labelRect = bodyLabel.frame;
    //    labelRect.size.height = textSize.height + 5;
    //    [bodyLabel setFrame:labelRect];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // When the clicks back button
    if ([text isEqualToString:@""]) {
        // Go through the array for Objects
        for (int i = 0; i < [rangeArray count]; i++) {
            NSRange range = [[rangeArray objectAtIndex:i] rangeValue];
            
            // Check if any added range is where we stand now
            int length = range.location + range.length;
            if (length == txtView.text.length) {
                // get the text with out aded string and replace it
                NSString * subStr = [textView.text substringToIndex:range.location];
                
                // Remove range from current and labels ranges array
                [rangeArray removeObject:[NSValue valueWithRange:range]];
                [txtView.rangesArray removeObject:[NSValue valueWithRange:range]];
                
                // Set the text with added
                [textView setText:subStr];
                return NO;
            }
        }
    }
    
    return YES;
}

#pragma mark - Button actions methods
- (void)buttonClicked:(UIButton *)sender
{
    // Get the current text
    NSString * textStr = txtView.text;
    
    // Get the Previously added values
    NSString *str = [objArray objectAtIndex:(value++)%3];
    
    // Create the final string to be replaced
    textStr = [textStr stringByAppendingString:str];
    
    // Make the NSRange for the string for storing
    NSRange range = NSMakeRange(txtView.text.length, str.length);
    
    [rangeArray addObject:[NSValue valueWithRange:range]];
    
    // Add the same range for labels string for drawing
    
    [txtView.rangesArray addObject:[NSValue valueWithRange:range]];
    
    [txtView setText:textStr];
}
@end
