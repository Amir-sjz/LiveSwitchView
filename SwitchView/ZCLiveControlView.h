//
//  ZCLiveControlView.h
//  SwitchView
//
//  Created by chengZ on 2017/8/27.
//  Copyright © 2017年 chengZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZCLiveControlViewDelegate <NSObject>
/**进行播放新的视频*/
- (void)playCurrentVideoWithIndex:(NSUInteger)index;
@end

@protocol ZCLiveControlViewDataSource <NSObject>
@required
/**数据数组*/
- (NSMutableArray *)videosForSwitchView;
/**请求上一页数据，如果没有上一页则返回NO*/
- (BOOL)loadPrePageData;
/**请求下一页数据，如果没有下一页则返回NO*/
- (BOOL)loadNextPageData;

@end

@interface ZCLiveControlView : UIView
@property (nonatomic, weak) id<ZCLiveControlViewDataSource> dataSource;
@property (nonatomic, weak) id<ZCLiveControlViewDelegate> delegate;

- (void)reloadSwitchView;

@end
