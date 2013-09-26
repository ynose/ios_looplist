//
//  UIProductCell.m
//  TapMailer
//
//  Created by Yoshio Nose on 12/03/27.
//  Copyright (c) 2012 ynose Apps. All rights reserved.
//

#import "UIProductCell.h"

#import "Define.h"
#import "UILabel+Align.h"

@implementation UIProductCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 機能名
        self.productLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 200, 20)];
        self.productLabel.font = UIFontStandardBold;
        self.productLabel.textAlignment = NSTextAlignmentLeft;
        self.productLabel.backgroundColor = [UIColor clearColor];
        self.productLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:self.productLabel];

        // 価格
        self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - 100, 12, 100, 20)];
        self.priceLabel.font = UIFontStandardBold;
        self.priceLabel.textAlignment = NSTextAlignmentLeft;
        self.priceLabel.backgroundColor = [UIColor clearColor];
        self.priceLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:self.priceLabel];

        // 説明文
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 38, self.contentView.frame.size.width - 20, 40)];
        self.descriptionLabel.font = [UIFont systemFontOfSize:14.0f];
        self.descriptionLabel.textColor = [UIColor darkGrayColor];
        self.descriptionLabel.textAlignment = NSTextAlignmentLeft;
        self.descriptionLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.descriptionLabel.backgroundColor = [UIColor clearColor];
        self.descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.descriptionLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.descriptionLabel verticalAlignTop];
}

@end
