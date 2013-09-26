//
//  UISettingSwitchCell.m
//  TapMailer
//
//  Created by Yoshio Nose on 11/11/18.
//  Copyright (c) 2011 ynose Apps. All rights reserved.
//

#import "UISettingSwitchCell.h"

@implementation UISettingSwitchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.delegate = self;
    }
    return self;
}

#pragma mark - スイッチのOn/Off
-(void)switchCellValueChanged:(UISimpleSwitchCell *)cell aSwitch:(UISwitch *)aSwitch
{
    if (self.userDefaultKey) {
        [[NSUserDefaults standardUserDefaults] setBool:cell.on forKey:self.userDefaultKey];
    }
}

@end
