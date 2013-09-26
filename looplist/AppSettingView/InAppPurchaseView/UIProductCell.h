//
//  UIProductCell.h
//  TapMailer
//
//  Created by Yoshio Nose on 12/03/27.
//  Copyright (c) 2012 ynose Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIProductCell : UITableViewCell

@property (nonatomic, strong) UILabel *productLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;

//- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;


@end
