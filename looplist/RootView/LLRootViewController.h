//
//  LLRootViewController.h
//  looplist
//
//  Created by Yoshio Nose on 2013/09/24.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LLCheckList.h"
#import "LLCheckItemCell.h"
#import "LLRootFooterView.h"
#import "LLCheckItemDetailViewController.h"
#import "LLCheckListDetailViewController.h"

#import "UITableView+Extension.h"

@interface LLRootViewController : UITableViewController <LLCheckItemCellDelegate, LLRootFooterViewDelegate,
                                                            LLCheckListDetailViewDelegate, LLDetailViewDelegate>
{
    __strong UILongPressGestureRecognizer *_longPressRecognizer;
    __strong UILongPressGestureRecognizer *_longPressEditRecognizer;
}

@property (assign, nonatomic) NSUInteger checkListIndex;
@property (strong, nonatomic) LLCheckList *checkList;
@property (weak, nonatomic, readonly) NSMutableArray *checkItems;

-(void)refreshTabBarItem;
-(NSIndexPath *)indexPathOfEndRow;
-(NSMutableArray *)checkListSections;

@end
