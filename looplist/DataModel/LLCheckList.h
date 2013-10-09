//
//  LLCheckList.h
//  Looplist
//
//  Created by Yoshio Nose on 2013/07/09.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _FilterIndex {
	kFilterAll = 0,
	kFilterUnchecked = 1
} FilterType;

@class LLCheckListSection;
@class LLCheckItem;
@interface LLCheckList : NSObject <NSCoding, NSCopying>

@property (copy, nonatomic) NSString *caption;
@property (strong, nonatomic) NSDate *createDate;
@property (strong, nonatomic) NSDate *finishDate;
@property (assign, nonatomic) NSInteger finishCount;
@property (assign, nonatomic) FilterType filterIndex;
@property (assign, nonatomic) BOOL saveToEvernote;
@property (copy, nonatomic) NSString *checkItemsFileName;
@property (strong, nonatomic) NSMutableArray *arraySections;                        // 全チェックアイテムを含むセクション

@property (strong, nonatomic, readonly) NSMutableArray *arrayUncheckedSections;     // 未チェックアイテムを含むセクション
@property (strong, nonatomic, readonly) NSMutableArray *arrayCheckedItems;          // チェック済みアイテム（全セクション）
@property (strong, nonatomic, readonly) NSMutableArray *arrayUncheckedItems;        // 未チェックアイテム（全セクション）
@property (assign, nonatomic, readonly) NSInteger numberOfAllCheckItems;            // 全セクションの全チェックアイテム数

-(id)initWithCheckItemsFileName;
-(NSInteger)incrementFinishCount;

-(void)addSection;
-(void)removeSection:(NSInteger)section;
-(void)moveSection:(NSInteger)fromSection toSection:(NSInteger)toSection;
-(LLCheckListSection *)sectionAtIndex:(NSInteger)sectionIndex;

-(NSInteger)sequenceOfCheckItem:(LLCheckItem *)checkItem;

@end
