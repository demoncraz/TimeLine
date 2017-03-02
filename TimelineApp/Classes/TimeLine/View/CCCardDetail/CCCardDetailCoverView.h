//
//  CCCardDetailCoverView.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/22.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCCommonCoverView.h"
#import "CCTaskCardItem.h"
@class CCCardDetailCoverView;

@protocol CCCardDetailCoverViewDelegate <NSObject>

- (void)CCCardDetailCoverView:(CCCardDetailCoverView *)coverView didChangeCompletion:(BOOL)isCompleted withTaskItem:(CCTaskCardItem *)item;

@end

@interface CCCardDetailCoverView : CCCommonCoverView

@property (nonatomic, weak) id<CCCardDetailCoverViewDelegate> delegate;

@property (nonatomic, weak) CCTaskCardItem *item;

- (void)showWithItem:(CCTaskCardItem *)item;

@end
