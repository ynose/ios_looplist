//
//  UISimpleSwitchCell.m
//  TapMailer
//
//  Created by Yoshio Nose on 11/11/16.
//  Copyright (c) 2011 ynose Apps. All rights reserved.
//

#import "UISimpleSwitchCell.h"
#import "Define.h"

@implementation UISimpleSwitchCell

@synthesize aSwitch = _aSwitch;
@synthesize iconView = _iconView;
@synthesize valueChangedBlock = _valueChangedBlock;

-(void)_setOn:(BOOL)on
{
    self.aSwitch.on = on;
}

-(BOOL)_getOn
{
    return self.aSwitch.on;
}

-(void)_setIcon:(UIImage *)icon
{
    self.iconView.image = icon;
}

-(UIImage *)_getIcon
{
    return _icon;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // セルの設定
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.textColor = self.textLabel.textColor;    // なぜかこれがないとUISwitchが表示されない
        self.textLabel.font = UIFontStandardBold;
        self.textLabel.adjustsFontSizeToFitWidth = NO;
        
        // スイッチの追加
        self.aSwitch = [[UISwitch alloc] init];
        // iOS4とiOS5ではスイッチのデザインもサイズも違うので横幅サイズから計算して位置を求める
        CGRect switchFrame = CGRectMake(self.contentView.frame.size.width - self.aSwitch.frame.size.width - 10, 8, 
                                        self.aSwitch.frame.size.width, self.aSwitch.frame.size.height);
        self.aSwitch.frame = switchFrame;
        self.aSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.aSwitch addTarget:self 
                         action:@selector(switchValueChangedAction:) 
               forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.aSwitch];
        
        // アイコンの追加
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(switchFrame.origin.x - 30, (44 - 18) / 2, 15, 15)];
        self.iconView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addSubview:self.iconView];
    }
    return self;
}

-(void)switchValueChangedAction:(UISwitch *)aSwitch
{
    if (_valueChangedBlock) _valueChangedBlock((UISwitch *)aSwitch);

    if ([self.delegate respondsToSelector:@selector(switchCellValueChanged:aSwitch:)]) {
        [self.delegate switchCellValueChanged:self aSwitch:aSwitch];
    }
}

@end
