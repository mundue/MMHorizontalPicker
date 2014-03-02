//
//  MMHorizontalPicker.m
//
//  Created by Matt Martel on 2/27/14.
//  Copyright (c) 2014 Mundue LLC. All rights reserved.
//

#import "MMHorizontalPicker.h"

@interface MMHorizontalPicker ()
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic) NSUInteger numberOfSegments;
@property (nonatomic) CGFloat segmentWidth;
@property (nonatomic) CGFloat segmentHeight;
@property (nonatomic) NSUInteger selectedSegment;
@end

static NSUInteger const kDefaultNumberOfSegments = 5;
static NSInteger const kSegmentBaseTag = 1000;
static NSInteger const kBarTag = 5000;
static CGFloat const kLabelHorizontalInset = 4.0f;
static CGFloat const kLabelVerticalInset = 10.0f;

@implementation MMHorizontalPicker

#pragma mark - UIView overrides

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Public methods

- (NSString *)labelForSegment:(NSUInteger)segment
{
    UILabel *label = (UILabel*)[self.scrollView viewWithTag:kSegmentBaseTag+segment];
    return label.text;
}

- (void)selectSegment:(NSUInteger)segment
{
    UILabel *label = (UILabel *)[self.scrollView viewWithTag:kSegmentBaseTag+segment];
    NSUInteger placeholderSegments = (self.numberOfVisibleSegments-1)/2;
    CGFloat x = label.frame.origin.x;
    x -= (placeholderSegments*self.segmentWidth);
    x -= kLabelHorizontalInset;
    CGPoint offset = CGPointMake(x, 0.0f);
    
    if (!CGPointEqualToPoint(offset, self.scrollView.contentOffset)) {
        [self.scrollView setContentOffset:offset animated:YES];
    
        if ([self.horizontalPickerDelegate respondsToSelector:@selector(pickerWillBeginDragging:)]) {
            [self.horizontalPickerDelegate pickerWillBeginDragging:self];
        }
        UIView *bar = [self viewWithTag:kBarTag];
        bar.hidden = YES;
    }
}

/*
 Segments arranged like this, so the first,last always centered:
 
 [placeholder][placeholder][1000...1000+n][placeholder][placeholder]
 
 */
- (void)layoutSubviews
{
    NSUInteger placeholderCount = (self.numberOfVisibleSegments-1)/2;
    NSUInteger segmentCount = [self.segments count];
    if (!segmentCount) {
        return;
    }
    if (!self.numberOfVisibleSegments) {
        return;
    }
    for (id subview in self.scrollView.subviews) {
        [subview removeFromSuperview];
    }
    self.numberOfSegments = segmentCount;
    self.segmentWidth = self.scrollView.frame.size.width/self.numberOfVisibleSegments;
    self.segmentHeight = self.scrollView.frame.size.height;
    segmentCount += (placeholderCount*2); // placeholder before + placeholder after
    NSUInteger index;
    // Add the empty "placeholder before" segments
    for (index = 0; index < placeholderCount; index++) {
        UILabel *label = [self makeSegment:nil];
        label.frame = CGRectInset(CGRectMake(self.segmentWidth*index, 0.0f, self.segmentWidth, self.segmentHeight),kLabelHorizontalInset,kLabelVerticalInset);
        [self.scrollView addSubview:label];
    }
    // Add the actual tappable segments
    for (index = placeholderCount; index < (segmentCount-placeholderCount); index++) {
        UILabel *label = [self makeSegment:self.segments[index-placeholderCount]];
        label.frame = CGRectInset(CGRectMake(self.segmentWidth*index, 0.0f, self.segmentWidth, self.segmentHeight),kLabelHorizontalInset,kLabelVerticalInset);
        label.tag = kSegmentBaseTag + (index-placeholderCount);
        [self.scrollView addSubview:label];
    }
    // Add the empty "placeholder after" segments
    for (index = (segmentCount-placeholderCount); index < segmentCount; index++) {
        UILabel *label = [self makeSegment:nil];
        label.frame = CGRectInset(CGRectMake(self.segmentWidth*index, 0.0f, self.segmentWidth, self.segmentHeight),kLabelHorizontalInset,kLabelVerticalInset);
        [self.scrollView addSubview:label];
    }
    // Force "scroll" to initial position
    self.scrollView.contentSize = CGSizeMake(self.segmentWidth*segmentCount, self.segmentHeight);
    // Slight offset, else it won't scroll at all
//    [self.scrollView setContentOffset:CGPointMake(1.0f, 0.0f) animated:YES];
    // Update bar geometry
    UIView *bar = [self viewWithTag:kBarTag];
    CGFloat barWidth = self.segmentWidth-(2*kLabelHorizontalInset);
    CGFloat barHeight = 2.0f;
    bar.frame = CGRectMake((self.frame.size.width/2.0f)-(barWidth/2.0f), (self.frame.size.height-6.0f), barWidth, barHeight);
    [self bringSubviewToFront:bar];
    // Make sure correct segment stays selected, after rotation
    [self selectSegment:self.selectedSegment];
}

#pragma mark - Private methods

- (void)commonInit
{
    // Initialization code
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height)];
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.scrollView];
    _numberOfSegments = 0;
    _numberOfVisibleSegments = kDefaultNumberOfSegments;
    _selectedSegment = 0;
    
    // Add a bar to "highlight" the selected segment
    UIView *bar = [[UIView alloc] initWithFrame:CGRectZero];
    bar.tag = kBarTag;
    bar.backgroundColor = [UIColor grayColor];
    bar.userInteractionEnabled = NO;
    bar.layer.cornerRadius = 2.0f;
    bar.layer.shadowColor = [[UIColor blackColor] CGColor];
    bar.layer.shadowRadius = 2.0f;
    bar.layer.shadowOpacity = 1.0f;
    bar.layer.shadowOffset = CGSizeZero;
    [self addSubview:bar];

    // Add tap handler gesture recognizer
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.scrollView addGestureRecognizer:gestureRecognizer];
}

- (void)setNumberOfVisibleSegments:(NSUInteger)numberOfVisibleSegments
{
    NSAssert(numberOfVisibleSegments%2==1, @"must have odd number of segments");
    _numberOfVisibleSegments = numberOfVisibleSegments;
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        NSUInteger placeholderSegments = (self.numberOfVisibleSegments-1)/2;
        NSUInteger firstSegment = placeholderSegments;
        NSUInteger lastSegment = self.numberOfSegments+placeholderSegments;
        CGPoint location = [sender locationInView:self.scrollView];
        location.x += self.scrollView.contentOffset.x;
        NSInteger index = (location.x/self.segmentWidth)-(self.scrollView.contentOffset.x/self.segmentWidth);
        if (index >= firstSegment && index < lastSegment) {
            CGPoint offset = CGPointMake((index-placeholderSegments)*self.segmentWidth, 0.0f);
            if (CGPointEqualToPoint(offset, self.scrollView.contentOffset)) {
                return;
            }
            [self.scrollView setContentOffset:offset animated:YES];
            if ([self.horizontalPickerDelegate respondsToSelector:@selector(pickerWillBeginDragging:)]) {
                [self.horizontalPickerDelegate pickerWillBeginDragging:self];
            }
            UIView *bar = [self viewWithTag:kBarTag];
            bar.hidden = YES;
        }
    }
}

- (UILabel *)makeSegment:(NSString *)name
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.minimumScaleFactor = 0.1;
    label.adjustsFontSizeToFitWidth = YES;
    label.text = name;
    if ([name length]) {
        label.backgroundColor = [UIColor grayColor];
    }
    return label;
}

#pragma mark - UIScrollViewDelegate protocol methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.horizontalPickerDelegate respondsToSelector:@selector(pickerWillBeginDragging:)]) {
        [self.horizontalPickerDelegate pickerWillBeginDragging:self];
    }
    UIView *bar = [self viewWithTag:kBarTag];
    bar.hidden = YES;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *) targetContentOffset
{
    NSInteger index = lrintf(targetContentOffset->x/self.segmentWidth);
    targetContentOffset->x = index*self.segmentWidth;
    
    if ([self.horizontalPickerDelegate respondsToSelector:@selector(pickerWillEndDragging:)]) {
        [self.horizontalPickerDelegate pickerWillEndDragging:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = lrintf(self.scrollView.contentOffset.x/self.segmentWidth);
    
    if ([self.horizontalPickerDelegate respondsToSelector:@selector(picker:didSelectSegment:)]) {
        [self.horizontalPickerDelegate picker:self didSelectSegment:index];
    }
    UIView *bar = [self viewWithTag:kBarTag];
    bar.hidden = NO;
    self.selectedSegment = index;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSInteger index = lrintf(self.scrollView.contentOffset.x/self.segmentWidth);
    
    if ([self.horizontalPickerDelegate respondsToSelector:@selector(picker:didSelectSegment:)]) {
        [self.horizontalPickerDelegate picker:self didSelectSegment:index];
    }
    UIView *bar = [self viewWithTag:kBarTag];
    bar.hidden = NO;
    self.selectedSegment = index;
}

@end
