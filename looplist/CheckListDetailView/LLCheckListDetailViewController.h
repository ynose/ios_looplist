//
//  LLCheckListSettingViewController.h
//  Looplist
//
//  Created by Yoshio Nose on 2013/08/12.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLSectionCell.h"

@class LLCheckList;

@protocol LLCheckListDetailViewDelegate <NSObject>
-(void)saveCheckListDetail:(LLCheckList *)checkList;
@end

//@protocol LLCheckListDetailDelegate <NSObject>
//-(void)deleteCheckListAtIndex:(NSInteger)checkListIndex;
//@end

@interface LLCheckListDetailViewController : UIViewController
{
    __strong UITextField *_activeTextField;
}

@property (weak, nonatomic) id<LLCheckListDetailViewDelegate> delegate;
//@property (weak, nonatomic) id<LLCheckListDetailDelegate> checkListDetailDelegate;
@property (assign, nonatomic) NSUInteger checkListIndex;
@property (copy, nonatomic) LLCheckList *checkList;

@property (weak, nonatomic) IBOutlet UITableView *sectionTableView;

-(void)resizeView;

@end


@interface LLCheckListDetailViewController (SectionTableView) <UITableViewDelegate, UITableViewDataSource, LLSectionCellDelegate>
-(void)setupSectionTableView;
@end