//
//  MMHorizontalPicker.h
//
//  Created by Matt Martel on 2/27/14.
//  Copyright (c) 2014 Mundue LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMHorizontalPickerDelegate;

@interface MMHorizontalPicker : UIView <UIScrollViewDelegate>
@property (nonatomic) NSUInteger numberOfVisibleSegments;
@property (nonatomic,weak) id<MMHorizontalPickerDelegate> horizontalPickerDelegate;
@property (nonatomic,copy) NSArray *segments;
- (NSString *)labelForSegment:(NSUInteger)segment;
- (void)selectSegment:(NSUInteger)segment;
@end

@protocol MMHorizontalPickerDelegate <NSObject>
@optional
- (void)pickerWillBeginDragging:(MMHorizontalPicker *)picker;
- (void)pickerWillEndDragging:(MMHorizontalPicker *)picker;
- (void)picker:(MMHorizontalPicker *)picker didSelectSegment:(NSUInteger)segment;
@end
