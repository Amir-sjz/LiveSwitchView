//
//  ViewController.m
//  SwitchView
//
//  Created by chengZ on 2017/8/27.
//  Copyright © 2017年 chengZ. All rights reserved.
//

#import "ViewController.h"


#import "ZCLiveControlView.h"


#define KMainScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define KMainScreenHeight ([UIScreen mainScreen].bounds.size.height)

@interface ViewController ()<ZCLiveControlViewDataSource, ZCLiveControlViewDelegate>
{
    ZCLiveControlView *liveView;
    CGFloat ratio;
}

@property (nonatomic, strong) NSMutableArray *videosArray;

@end

@implementation ViewController

- (void)dealloc
{
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    ratio = 3.0;
    
    liveView = [[ZCLiveControlView alloc] initWithFrame:CGRectMake((KMainScreenWidth-KMainScreenWidth/ratio)/2, (KMainScreenHeight-KMainScreenHeight/ratio)/2, KMainScreenWidth/ratio, KMainScreenHeight/ratio)];
    [self.view addSubview:liveView];
    
    liveView.dataSource = self;
    
    NSArray *array = @[[UIColor redColor], [UIColor blueColor], [UIColor greenColor]];
    self.videosArray = [NSMutableArray arrayWithArray:array];
}

#pragma mark - ZCLiveControlViewDataSource
- (NSMutableArray *)videosForSwitchView {
    return self.videosArray;
}

BOOL isPrePage = YES;
- (BOOL)loadPrePageData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{ // 加载上一页数据
            NSArray *array = @[[UIColor orangeColor], [UIColor brownColor]];
            [self.videosArray insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]];
        });
        isPrePage = NO;
        [liveView reloadSwitchView];
    });
    
    return isPrePage;
}

BOOL isNextPage = YES;
- (BOOL)loadNextPageData {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{ // 加载下一页数据
            NSArray *array = @[[UIColor grayColor], [UIColor whiteColor]];
            [self.videosArray addObjectsFromArray:array];
        });
        isNextPage = NO;
        [liveView reloadSwitchView];
    });
    
    return isNextPage;
}

- (void)playCurrentVideoWithIndex:(NSUInteger)index {
    id obj = [self.videosArray objectAtIndex:index];
    NSLog(@"-----%@------", obj);
}

#pragma mark -

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint lastPoint = [touch previousLocationInView:liveView];
    CGPoint currentPoint = [touch locationInView:liveView];
    
    if (ABS(currentPoint.x - lastPoint.x) > ABS(currentPoint.y - lastPoint.y)) {
        // 左右滑动
        // 左滑
        ratio += (currentPoint.x - lastPoint.x)/100;
        if (ratio<=1) {
            ratio = 1.0;
        } else if (ratio >= 5) {
            ratio = 5.0f;
        }
        // 右滑
        
        liveView.frame = CGRectMake((KMainScreenWidth-KMainScreenWidth/ratio)/2, (KMainScreenHeight-KMainScreenHeight/ratio)/2, KMainScreenWidth/ratio, KMainScreenHeight/ratio);
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}



@end
