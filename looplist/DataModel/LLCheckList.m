//
//  LLCheckList.m
//  EverList
//
//  Created by Yoshio Nose on 2013/07/09.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "Define.h"
#import "LLCheckListManager.h"
#import "LLCheckList.h"
#import "LLCheckListSection.h"
#import "LLCheckItem.h"


@implementation LLCheckList

-(id)init
{
    self = [super init];
    if (self) {
        self.caption = LSTR(@"NewCheckListCaption");
        self.createDate = [NSDate date];
        self.finishCount = 0;
        self.filterIndex = kFilterAll;
        self.saveToEvernote = NO;
        self.arraySections = [NSMutableArray arrayWithObject:[LLCheckListSection new]];
    }

    return self;
}

-(id)initWithCheckItemsFileName
{
    self = [self init];
    if (self) {
        self.checkItemsFileName = [NSString stringWithFormat:@"checkitems_%@.dat", [[NSUUID UUID] UUIDString]];
        DEBUGLOG("LLCheckList FileName = %@", self.checkItemsFileName);
    }

    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }

    self.caption = [aDecoder decodeObjectForKey:@"caption"];
    self.createDate = [aDecoder decodeObjectForKey:@"createDate"];
    if (!self.createDate) {
        self.createDate = [NSDate date];
    }
    self.finishCount = [aDecoder decodeIntegerForKey:@"finishCount"];
    self.filterIndex = [aDecoder decodeIntegerForKey:@"filterIndex"];
    self.saveToEvernote = [aDecoder decodeBoolForKey:@"saveToEvernote"];
    self.checkItemsFileName = [aDecoder decodeObjectForKey:@"checkListFileName"];

    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.caption forKey:@"caption"];
    [aCoder encodeObject:self.createDate forKey:@"createDate"];
    [aCoder encodeInteger:self.finishCount forKey:@"finishCount"];
    [aCoder encodeInteger:self.filterIndex forKey:@"filterIndex"];
    [aCoder encodeBool:self.saveToEvernote forKey:@"saveToEvernote"];
    [aCoder encodeObject:self.checkItemsFileName forKey:@"checkListFileName"];
}

-(id)copyWithZone:(NSZone *)zone
{
    LLCheckList *clone = [[[self class] allocWithZone:zone] init];
    clone.caption = [self caption];
    clone.createDate = [self createDate];
    clone.finishCount = [self finishCount];
    clone.filterIndex = [self filterIndex];
    clone.saveToEvernote = [self saveToEvernote];
    clone.checkItemsFileName = [self checkItemsFileName];
    clone.arraySections = [self arraySections];

    return clone;
}

-(NSInteger)incrementFinishCount
{
    if (self.finishCount < MAX_FINISHCOUNT) {
        return self.finishCount++;
    } else {
        return self.finishCount;
    }
}

#pragma mark - CheckListSection操作
-(void)addSection
{
    [self.arraySections addObject:[LLCheckListSection new]];
}

-(void)removeSection:(NSInteger)section
{
    // 先頭以外のセクションの場合は含まれているチェックアイテムを１つ前のセクションに移動する
    if (section > 0) {
        while (0 < [((LLCheckListSection *)self.arraySections[section]).checkItems count]) {
            [[LLCheckListManager sharedManager] moveCheckItem:[NSIndexPath indexPathForRow:0 inSection:section] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:section - 1] inCheckList:0];
        }
    }
    // セクションのタイトルをクリア
    ((LLCheckListSection *)self.arraySections[section]).caption = nil;

    [self.arraySections removeObjectAtIndex:section];
}

-(void)moveSection:(NSInteger)fromSection toSection:(NSInteger)toSection
{
    __strong LLCheckListSection *checkListSection = (LLCheckListSection *)self.arraySections[fromSection];
    [self.arraySections removeObject:checkListSection];
    [self.arraySections insertObject:checkListSection atIndex:toSection];
}

-(LLCheckListSection *)sectionAtIndex:(NSInteger)sectionIndex
{
    return (LLCheckListSection *)self.arraySections[sectionIndex];
}


#pragma mark - チェックアイテムの通し番号
-(NSInteger)sequenceOfCheckItem:(LLCheckItem *)checkItem
{
    NSInteger seq = 0;
    NSInteger row = NSNotFound;

    for (NSInteger section = 0; section < [self.arraySections count] && row == NSNotFound; section++) {
        if ([self.arraySections[section] isKindOfClass:[LLCheckListSection class]]) {
            row = [[self sectionAtIndex:section].checkItems indexOfObject:checkItem];
        } else {
            row = 0;
        }
        if (row == NSNotFound) {
            seq += [[self sectionAtIndex:section].checkItems count];
        }
    }
    return seq + (row + 1);
}


#pragma mark - 未チェックcheckItemを含むセクションの配列
-(NSMutableArray *)arrayUncheckedSections
{
    static NSString *format = @"SELF.checkedDate = nil";

    NSMutableArray *newSections = [NSMutableArray array];
    for (LLCheckListSection *checkListSection in self.arraySections) {
        if ([checkListSection isKindOfClass:[LLCheckListSection class]]) {
            NSArray *checkItems = [checkListSection.checkItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:format]];
            if ([checkItems count] > 0) {
                // 未チェックcheckItemを含むセクションを追加する
                [newSections addObject:[[LLCheckListSection alloc] initWithCaption:checkListSection.caption
                                                                        checkItems:(NSMutableArray *)checkItems]];
            } else {
                [newSections addObject:[[LLCheckListSection alloc] initWithCaption:checkListSection.caption
                                                                        checkItems:[NSMutableArray array]]];
            }
        }
    }

    return newSections;
}

#pragma mark チェック済みcheckItemsの配列
-(NSMutableArray *)arrayCheckedItems
{
    static NSString *format = @"SELF.checkedDate != nil";

    return [self filteredCheckItemUsingPredicate:[NSPredicate predicateWithFormat:format]];
}

#pragma mark 未チェックcheckItemsの配列
-(NSMutableArray *)arrayUncheckedItems
{
    static NSString *format = @"SELF.checkedDate = nil";

    return [self filteredCheckItemUsingPredicate:[NSPredicate predicateWithFormat:format]];
}

// 全セクションのチェックアイテムを対象にフィルタをかけてアイテムの配列を返す
-(NSMutableArray *)filteredCheckItemUsingPredicate:(NSPredicate *)predicate
{
    NSMutableArray *newCheckItems = [NSMutableArray array];
    for (LLCheckListSection *checkListSection in self.arraySections) {
        if ([checkListSection isKindOfClass:[LLCheckListSection class]]) {
            NSArray *checkItems = [checkListSection.checkItems filteredArrayUsingPredicate:predicate];
            if ([checkItems count] > 0) {
                [newCheckItems addObjectsFromArray:checkItems];
            }
        }
    }

    return newCheckItems;
}

@end
