//
//  UISimpleSwitchCell.h
//  TapMailer
//
//  Created by Yoshio Nose on 11/11/16.
//  Copyright (c) 2011 ynose Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UISimpleSwitchCell;

@protocol SimpleSwitchCellDelegate <NSObject>
@required
-(void)switchCellValueChanged:(UISimpleSwitchCell *)cell aSwitch:(UISwitch *)aSwitch;
@end

@interface UISimpleSwitchCell : UITableViewCell
{
    BOOL _on;
    UIImage *_icon;
}

@property (nonatomic, assign) id <SimpleSwitchCellDelegate> delegate;
@property (nonatomic, assign, getter = _getOn, setter = _setOn:) BOOL on;
@property (nonatomic, assign, getter = _getIcon, setter = _setIcon:) UIImage *icon;
@property (nonatomic, retain) UIImageView *iconView;
@property (nonatomic, retain) UISwitch *aSwitch;
@property (nonatomic, copy) void (^valueChangedBlock)(UISwitch *);

-(void)switchValueChangedAction:(UISwitch *)aSwitch;

@end
