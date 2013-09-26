//
//  LLcolorLabelButton.m
//  Looplist
//
//  Created by Yoshio Nose on 2013/08/30.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLColorLabelButton.h"

@implementation LLColorLabelButton


//-(id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//    }
//
//    return self;
//}

-(void)layoutSubviews
{
    [super layoutSubviews];

    self.buttonCornerRadius = 40.0f;
    [self setGradientType: kUIGlossyButtonGradientTypeSolid];
}

-(void)setColorLabelIndex:(NSInteger)colorLabelIndex
{
    _colorLabelIndex = colorLabelIndex;

    self.tintColor = [self labelcolorAtIndex:_colorLabelIndex];
    self.disabledColor = self.tintColor;
    [self setTitleColor:[self titleColorAtIndex:_colorLabelIndex] forState:UIControlStateNormal];
}

-(UIColor *)labelcolorAtIndex:(NSInteger)colorIndex
{
    switch (colorIndex) {
        case 1:
            return [UIColor colorWithRed:0.804 green:0.380 blue:0.396 alpha:1.000];
            break;
        case 2:
            return [UIColor colorWithRed:0.773 green:0.584 blue:0.349 alpha:1.000];
            break;
        case 3:
            return [UIColor colorWithRed:0.796 green:0.710 blue:0.204 alpha:1.000];
            break;
        case 4:
            return [UIColor colorWithRed:0.647 green:0.702 blue:0.349 alpha:1.000];
            break;
        case 5:
            return [UIColor colorWithRed:0.369 green:0.494 blue:0.780 alpha:1.000];
            break;
        default:
            return [UIColor whiteColor];
            break;
    }
}

-(UIColor *)titleColorAtIndex:(NSInteger)colorIndex
{
    switch (colorIndex) {
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
            return [UIColor whiteColor];
            break;
        default:
            return [UIColor colorWithRed:0.784 green:0.788 blue:0.702 alpha:1.000];
            break;
    }
}

@end
