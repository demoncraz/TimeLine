//
//  CCDatePicker.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/3.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CCDatePicker;

@protocol CCDatePickerDelegate <NSObject>

- (void)didDismissDatePicker:(CCDatePicker *)datePicker;

- (void)datePicker:(CCDatePicker *)datePicker didChangeDate:(NSDate *)date;

- (void)datePicker:(CCDatePicker *)datePicker didConfirmDate:(NSDate *)date;


@end

@interface CCDatePicker : UIView

@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, weak) id<CCDatePickerDelegate> delegate;

- (void)dismiss;

@end
