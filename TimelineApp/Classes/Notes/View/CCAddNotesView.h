//
//  CCAddNotesView.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/20.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CCAddNotesView;

@protocol CCAddNotesViewDelegate <NSObject>

- (void)addNotesViewWillDismiss:(CCAddNotesView *)addNotesView;
- (void)addNotesView:(CCAddNotesView *)addNotesView didConfirmWithContent:(NSString *)content createDate:(NSDate *)date;

@end

@interface CCAddNotesView : UIView

@property (nonatomic, weak) id<CCAddNotesViewDelegate> delegate;


+ (instancetype)addNotesView;

- (void)startEdting;

@end
