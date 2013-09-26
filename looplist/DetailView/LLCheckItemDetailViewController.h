//
//  LLDetailViewController.h
//  EverList
//
//  Created by Yoshio Nose on 2013/07/22.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LLCheckItem;

@protocol LLDetailViewDelegate <NSObject>
-(void)saveDetail:(LLCheckItem *)checkItem;
@end

@interface LLCheckItemDetailViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>
{
    __strong UITextView *_activeTextView;
}

@property (weak, nonatomic) id<LLDetailViewDelegate> delegate;
@property (assign, nonatomic) NSUInteger sequenceNumber;
@property (copy, nonatomic) LLCheckItem *checkItem;

@end
