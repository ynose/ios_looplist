//
//  LLNavigationBar.m
//  looplist
//
//  Created by Yoshio Nose on 2013/10/01.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLNavigationBar.h"

@interface LLNavigationBar()
@property (nonatomic, strong) CALayer *colorLayer;
@end

@implementation LLNavigationBar

static CGFloat const kDefaultColorLayerOpacity = 0.5f;
static CGFloat const kSpaceToCoverStatusBars = 20.0f;

- (void)setBarTintColor:(UIColor *)barTintColor {
    [super setBarTintColor:barTintColor];
    if (self.colorLayer == nil) {
        self.colorLayer = [CALayer layer];
        self.colorLayer.opacity = kDefaultColorLayerOpacity;
        [self.layer addSublayer:self.colorLayer];
    }
    self.colorLayer.backgroundColor = barTintColor.CGColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.colorLayer != nil) {
        self.colorLayer.frame = CGRectMake(0, 0 - kSpaceToCoverStatusBars, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) + kSpaceToCoverStatusBars);

        [self.layer insertSublayer:self.colorLayer atIndex:1];
    }
}

@end
