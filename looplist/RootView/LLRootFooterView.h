//
//  LLRootFooterView.h
//  EverList
//
//  Created by Yoshio Nose on 2013/07/19.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LLRootFooterViewDelegate <NSObject>
-(void)checklistDetailButtonTouchUp:(id)sender;
-(void)completeCheckList:(UIControl *)sender;
@end

@interface LLRootFooterView : UIView
{
    __strong UITapGestureRecognizer *_tapRecognizer;
}

@property (nonatomic, weak) id<LLRootFooterViewDelegate> delegate;
@property (nonatomic, assign) BOOL editing;

+(LLRootFooterView *)view;

@end
