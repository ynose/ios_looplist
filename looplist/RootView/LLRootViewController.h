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
#import "LLCheckItemDetailViewController.h"
#import "LLCheckListDetailViewController.h"

#import "UITableView+Extension.h"


static NSString *kCellIdentifier = @"Cell";

@interface LLRootViewController : UITableViewController <LLCheckItemCellDelegate, LLDetailViewDelegate>
{
    __strong UILongPressGestureRecognizer *_longPressRecognizer;
    __strong UILongPressGestureRecognizer *_longPressEditRecognizer;
    CGPoint _scrollBeginingPoint;
}


@property (assign, nonatomic) NSUInteger checkListIndex;
@property (strong, nonatomic) LLCheckList *checkList;
@property (assign, nonatomic) BOOL singleViewMode;
@property (strong, nonatomic) NSIndexPath *indexPathOfNeedFirstResponder;
@property (strong, nonatomic) NSIndexPath *indexPathOfSelected;

-(void)refreshTabBarItem;
-(NSIndexPath *)indexPathOfEndRow;
-(NSMutableArray *)checkListSections;

// LLRootViewController (TableView)で使用できるようにするため
@property (assign, nonatomic) BOOL finishAction;
@property (strong, nonatomic) NSIndexPath *editIndexPath;

-(LLCheckListSection *)checkListSection:(NSInteger)section;
-(LLCheckItem *)checkItemAtIndexPath:(NSIndexPath *)indexPath;
-(NSIndexPath *)indexPathOfNextRow:(NSIndexPath *)indexPath;

@end
