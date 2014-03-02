//
//  MonthsViewController.m
//  PickerTester
//
//  Created by Matt Martel on 3/2/14.
//  Copyright (c) 2014 Mundue LLC. All rights reserved.
//

#import "MonthsViewController.h"
#import "MMHorizontalPicker.h"

@interface MonthsViewController () <MMHorizontalPickerDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet MMHorizontalPicker *picker;
- (void)scrollToCurrentMonth;
- (void)updateContentsWithText:(NSString *)text;
@end

static NSUInteger const kLabelTag = 100;
static NSUInteger const kActivityTag = 101;

@implementation MonthsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.picker.horizontalPickerDelegate = self;
    self.picker.numberOfVisibleSegments = 5;
    self.picker.segments = @[@"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self performSelector:@selector(scrollToCurrentMonth) withObject:nil afterDelay:0.5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void)scrollToCurrentMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth fromDate:[NSDate date]];
    [self.picker selectSegment:components.month-1];
}

- (void)updateContentsWithText:(NSString *)text
{
    UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[self.contentView viewWithTag:kActivityTag];
    [activity stopAnimating];
    activity.hidden = YES;
    UILabel *label = (UILabel*)[self.contentView viewWithTag:kLabelTag];
    label.hidden = NO;
    label.text = text;
}
#pragma mark - MMHorizontalPickerDelegate protocol methods

- (void)pickerWillBeginDragging:(MMHorizontalPicker *)picker
{
    UILabel *label = (UILabel*)[self.contentView viewWithTag:kLabelTag];
    label.hidden = YES;
    UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[self.contentView viewWithTag:kActivityTag];
    activity.hidden = NO;
    [activity startAnimating];
}

- (void)pickerWillEndDragging:(MMHorizontalPicker *)picker
{
    
}

- (void)picker:(MMHorizontalPicker *)picker didSelectSegment:(NSUInteger)segment
{
    NSString *text = [picker labelForSegment:segment];
    [self updateContentsWithText:text];
}

@end
