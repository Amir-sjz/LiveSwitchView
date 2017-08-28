//
//  ZCLiveInfoView.m
//  SwitchView
//
//  Created by chengZ on 2017/8/27.
//  Copyright © 2017年 chengZ. All rights reserved.
//

#import "ZCLiveInfoView.h"
#import "Masonry.h"

@interface ZCLiveInfoView ()
@property (nonatomic, strong) UIImageView *imageView;
@end
@implementation ZCLiveInfoView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"123.png"] highlightedImage:[UIImage imageNamed:@"123.png"]];
        [self addSubview:self.imageView];
        
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY);
            make.height.width.equalTo(self.mas_width).multipliedBy(0.5);
        }];
    }
    return self;
}

@end
