//
//  ZCLiveControlView.m
//  SwitchView
//
//  Created by chengZ on 2017/8/27.
//  Copyright © 2017年 chengZ. All rights reserved.
//

#import "ZCLiveControlView.h"
#import "ZCLiveBgView.h"
#import "ZCLiveInfoView.h"
#import "Masonry.h"


@interface ZCLiveControlView ()
{
    CGFloat K_MainWidth;
    CGFloat K_MainHeight;
    
    NSUInteger currentIndex;
    
}
@property (nonatomic, strong) ZCLiveBgView *topBgView, *midBgView, *bottomBgView;
@property (nonatomic, strong) NSArray *imgArray;
@property (nonatomic, assign) NSUInteger currentVideoIndex;
@end

@implementation ZCLiveControlView

- (void)dealloc
{
    @try {
        [self.midBgView removeObserver:self forKeyPath:@"frame"];
    } @catch (NSException *exception) {
        
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        K_MainWidth = self.bounds.size.width;
        K_MainHeight = self.bounds.size.height;
        
        self.currentVideoIndex = 0;
        
        
        CGRect midFrame = self.bounds;
        
        CGRect topFrame = midFrame;
        topFrame.origin.y -= K_MainHeight;
        
        CGRect bottomFrame = midFrame;
        bottomFrame.origin.y += K_MainHeight;
        
        self.midBgView = [[ZCLiveBgView alloc] initWithFrame:midFrame];
        self.topBgView = [[ZCLiveBgView alloc] initWithFrame:topFrame];
        self.bottomBgView = [[ZCLiveBgView alloc] initWithFrame:bottomFrame];
        
        
        @try {
            [self.midBgView removeObserver:self forKeyPath:@"frame"];
        } @catch (NSException *exception) {
        }
        
        [self.midBgView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        
        [self addSubview:self.topBgView];
        [self addSubview:self.midBgView];
        [self addSubview:self.bottomBgView];
        
        ZCLiveInfoView *infoView = [[ZCLiveInfoView alloc] init];
        [self.midBgView addSubview:infoView];
        [infoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.midBgView);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect tempFrame = self.midBgView.frame;
    tempFrame.size = self.bounds.size;
    K_MainHeight = tempFrame.size.height;
    K_MainWidth = tempFrame.size.width;
    self.midBgView.frame = tempFrame;
    
    self.midBgView.backgroundColor = [self currentColor];
    self.topBgView.backgroundColor = [self preColor];
    self.bottomBgView.backgroundColor = [self nextColor];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        CGRect midFrame = self.midBgView.frame;
        self.topBgView.frame = CGRectMake(midFrame.origin.x, midFrame.origin.y-K_MainHeight, K_MainWidth, K_MainHeight);
        self.bottomBgView.frame = CGRectMake(midFrame.origin.x, midFrame.origin.y+K_MainHeight, K_MainWidth, K_MainHeight);
    }
}

#pragma mark - UI
- (void)reloadSwitchView {
    self.midBgView.backgroundColor = [self currentColor];
    self.topBgView.backgroundColor = [self preColor];
    self.bottomBgView.backgroundColor = [self nextColor];
}

#pragma mark - touch

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    CGPoint lastPoint = [touch previousLocationInView:self.midBgView];
    CGPoint currentPoint = [touch locationInView:self.midBgView];
    
    CGRect tempFrame = self.midBgView.frame;
    tempFrame.origin.y += currentPoint.y - lastPoint.y;//上下滑动
    tempFrame.origin.x = 0;
    
    self.midBgView.frame = tempFrame;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self changeFrame];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self changeFrame];
}

- (void)changeFrame {
    
    // 第一页 向上翻 并且可以请求上一页数据
    BOOL prePage = self.currentVideoIndex == 0 && self.midBgView.frame.origin.y>0;
    
    if (prePage) {
        prePage = prePage && [self hasPrePage];
    }
    
    // 最后一页 向下翻 并且可以请求下一页数据
    BOOL nextPage = self.currentVideoIndex == self.imgArray.count-1 && self.midBgView.frame.origin.y<0;
    if (nextPage) {
        nextPage = nextPage && [self hasNextPage];
    }
    
    if (prePage || nextPage) {
        // 当前页
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = self.midBgView.frame;
            frame.origin.y = 0;
            self.midBgView.frame = frame;
        }];
        return;
    }
    
    
    if (self.midBgView.frame.origin.y > K_MainHeight * 0.2) {
        // 上一页
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = self.midBgView.frame;
            frame.origin.y = K_MainHeight;
            self.midBgView.frame = frame;
        } completion:^(BOOL finished) {
            CGRect frame = self.midBgView.frame;
            frame.origin.y = 0;
            [self preColorSetting];
            self.midBgView.frame = frame;
            if ([self.delegate respondsToSelector:@selector(playCurrentVideoWithIndex:)]) {
                [self.delegate playCurrentVideoWithIndex:self.currentVideoIndex];
            }
        }];
        
    }  else if (self.midBgView.frame.origin.y < -K_MainHeight * 0.2) {
        // 下一页
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = self.midBgView.frame;
            frame.origin.y = -K_MainHeight;
            self.midBgView.frame = frame;
        } completion:^(BOOL finished) {
            CGRect frame = self.midBgView.frame;
            frame.origin.y = 0;
            [self nextColorSetting];
            self.midBgView.frame = frame;
            if ([self.delegate respondsToSelector:@selector(playCurrentVideoWithIndex:)]) {
                [self.delegate playCurrentVideoWithIndex:self.currentVideoIndex];
            }
        }];
    } else {
        // 当前页
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = self.midBgView.frame;
            frame.origin.y = 0;
            self.midBgView.frame = frame;
        }];
    }
}

#pragma mark - getter

- (NSArray *)imgArray {
    _imgArray = [self.dataSource videosForSwitchView];
    return _imgArray;
}


- (NSUInteger)currentVideoIndex {
    id obj = self.midBgView.backgroundColor;
    if (!obj) {
        obj = [self.imgArray objectAtIndex:_currentVideoIndex];
    }
    return [self.imgArray indexOfObject:obj];
}

#pragma mark - 上一个下一个操作
- (UIColor *)currentColor {
    if (self.currentVideoIndex<self.imgArray.count) {
        return self.imgArray[self.currentVideoIndex];
    }
    return nil;
}

- (UIColor *)preColor {
    if (0==self.currentVideoIndex && ![self hasPrePage]) { // 第一个的上一个是最后一个
        return self.imgArray[self.imgArray.count-1];
    }
    
    if (self.currentVideoIndex>0 && self.currentVideoIndex-1<self.imgArray.count) {
        return self.imgArray[self.currentVideoIndex-1];
    }
    return nil;
}

- (UIColor *)nextColor {
    if (self.imgArray.count-1 == self.currentVideoIndex && ![self hasNextPage]) { // 最后一个的下一个是第一个
        return self.imgArray[0];
    }
    
    if (self.currentVideoIndex+1<self.imgArray.count) {
        return self.imgArray[self.currentVideoIndex+1];
    }
    return nil;
}

- (void)nextColorSetting {
    self.midBgView.backgroundColor = [self nextColor];
    self.topBgView.backgroundColor = [self preColor];
    self.bottomBgView.backgroundColor = [self nextColor];
}

- (void)preColorSetting {
    self.midBgView.backgroundColor = [self preColor];
    self.topBgView.backgroundColor = [self preColor];
    self.bottomBgView.backgroundColor = [self nextColor];
}

// 是否有上一页
- (BOOL)hasPrePage {
    return [self.dataSource loadPrePageData];
}

// 是否有下一页
- (BOOL)hasNextPage {
    return [self.dataSource loadNextPageData];
}

#pragma mark - 
//- (UIColor *)currentColor {
//    if (currentIndex<self.imgArray.count) {
//        return self.imgArray[currentIndex];
//    }
//    return nil;
//}
//
//- (UIColor *)preColor {
//    if (0==currentIndex) { // 第一个的上一个是最后一个
//        return self.imgArray[self.imgArray.count-1];
//    }
//    
//    if (currentIndex>0 && currentIndex-1<self.imgArray.count) {
//        return self.imgArray[currentIndex-1];
//    }
//    return nil;
//}
//
//- (UIColor *)nextColor {
//    if (self.imgArray.count-1 == currentIndex) { // 最后一个的下一个是第一个
//        return self.imgArray[0];
//    }
//    
//    if (currentIndex+1<self.imgArray.count) {
//        return self.imgArray[currentIndex+1];
//    }
//    return nil;
//}
//
//- (void)nextColorSetting {
//    self.midBgView.backgroundColor = [self nextColor];
//    if (self.imgArray.count-1 == currentIndex) {
//        currentIndex = 0;
//    } else {
//        currentIndex++;
//    }
//    self.topBgView.backgroundColor = [self preColor];
//    self.bottomBgView.backgroundColor = [self nextColor];
//}
//
//- (void)preColorSetting {
//    self.midBgView.backgroundColor = [self preColor];
//    
//    if (0==currentIndex) {
//        currentIndex = self.imgArray.count-1;
//    } else {
//        currentIndex--;
//    }
//    self.topBgView.backgroundColor = [self preColor];
//    self.bottomBgView.backgroundColor = [self nextColor];
//}
@end
