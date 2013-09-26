//
//  UISettingSwitchCell.h
//  TapMailer
//
//  Created by Yoshio Nose on 11/11/18.
//  Copyright (c) 2011 ynose Apps. All rights reserved.
//

#import "UISimpleSwitchCell.h"

@interface UISettingSwitchCell : UISimpleSwitchCell <SimpleSwitchCellDelegate>

@property (nonatomic, copy) NSString *userDefaultKey;

@end
