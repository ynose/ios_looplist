//
//  LLCheckListManager+CheckItem.m
//  Looplist
//
//  Created by Yoshio Nose on 2013/08/27.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLCheckListManager.h"
#import "NSFileCoordinator+Extension.h"


@implementation LLCheckListManager (CheckItem)

static NSString *kKVOCheckedDate = KVO_CHECKEDDATE;

-(void)loadCheckItems
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dir = [self dir];

    for (LLCheckList *checkList in self.arrayCheckLists) {
        NSString *path = [dir stringByAppendingPathComponent:checkList.checkItemsFileName];
        NSMutableArray *checkListSections;
        if (!path || ![fileManager fileExistsAtPath:path]) {
            checkListSections = [NSMutableArray arrayWithObject:[LLCheckListSection new]];       // 空データ（必ず１つセクションを作る）
        } else {
            checkListSections = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            if (!checkListSections) {
                checkListSections = [NSMutableArray arrayWithObject:[LLCheckListSection new]];    // 空データ（必ず１つセクションを作る）
            }
        }

        checkList.arraySections = checkListSections;
    }
}

-(void)saveCheckItems
{
    for (int index = 0; index < [self.arrayCheckLists count]; index++) {
        [self saveCheckItemsInCheckList:index];
    }
}

-(void)saveCheckItemsInCheckList:(NSInteger)checkListIndex
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dir = [self dir];

    // ディレクトリを作成
    if (![fileManager fileExistsAtPath:dir]) {
        NSError *error;
        [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
    }

    // ファイルを保存(LLChecklist(index)をLLCheckList(index).filNameの名前で保存する)
    LLCheckList *checkList = (LLCheckList *)self.arrayCheckLists[checkListIndex];
    NSString *path = [dir stringByAppendingPathComponent:checkList.checkItemsFileName];
    [NSKeyedArchiver archiveRootObject:checkList.arraySections toFile:path];
}

#pragma mark 不要ファイルの削除
-(void)disposeGarbageFilesAtURL:(NSArray *)oldFileURLs
{
    // 復元した結果、使用されなくなるテンプレートファイルを削除
    NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    for (NSURL *oldFileURL in oldFileURLs) {
        NSString *oldFile = [oldFileURL lastPathComponent];
        BOOL equal = NO;
        for (LLCheckList *checkList in self.arrayCheckLists) {
            NSString *newFile = [[self URLForCheckListFileAtFileName:checkList.checkItemsFileName] lastPathComponent];
            if ([newFile isEqualToString:oldFile]) {
                equal = YES;
                break;
            }
        }
        if (equal == NO) {
            [fileCoordinator removeFile:oldFileURL];
        }
    }
}

#pragma mark - Checklist操作
-(NSIndexPath *)addCheckItem:(LLCheckItem *)checkItem section:(NSInteger)section inCheckList:(NSUInteger)checkListIndex
{
    LLCheckList *checkList = (LLCheckList *)self.arrayCheckLists[checkListIndex];
    NSInteger numberOfRows = [[checkList sectionAtIndex:section].checkItems count];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numberOfRows inSection:section];

    // 最終Sectionの末尾行に追加する
    [self insertCheckItem:checkItem atIndexPath:indexPath inCheckList:checkListIndex];

    // 追加した位置をIndexPathで返す
    return indexPath;
}

-(void)insertCheckItem:(LLCheckItem *)checkItem atIndexPath:(NSIndexPath *)indexPath inCheckList:(NSUInteger)checkListIndex
{
    [((LLCheckListSection *)((LLCheckList *)self.arrayCheckLists[checkListIndex]).arraySections[indexPath.section]).checkItems
                                                                                                            insertObject:checkItem
                                                                                                                atIndex:indexPath.row];
}

-(void)removeCheckItem:(LLCheckItem *)checkItem inCheckList:(NSUInteger)checkListIndex
{
    for (LLCheckListSection *checkListSection in ((LLCheckList *)self.arrayCheckLists[checkListIndex]).arraySections) {
        if ([checkListSection.checkItems indexOfObject:checkItem] != NSNotFound) {
            // 古いオブザーバーの削除
            if (checkItem.keyValueObserver) {
                [checkItem removeObserver:checkItem.keyValueObserver forKeyPath:kKVOCheckedDate];
                DEBUGLOG(@"removeObserver %@", checkItem.caption);
            }
            checkItem.keyValueObserver = nil;

            [checkListSection.checkItems removeObject:checkItem];
            break;
        }
    }
}

-(void)moveCheckItem:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath inCheckList:(NSUInteger)checkListIndex
{
    NSMutableArray *sections = ((LLCheckList *)self.arrayCheckLists[checkListIndex]).arraySections;

    __strong LLCheckItem *checkItem = ((LLCheckListSection *)sections[fromIndexPath.section]).checkItems[fromIndexPath.row];
    [((LLCheckListSection *)sections[fromIndexPath.section]).checkItems removeObject:checkItem];
    [((LLCheckListSection *)sections[toIndexPath.section]).checkItems insertObject:checkItem atIndex:toIndexPath.row];
}

-(void)replaceCheckItem:(LLCheckItem *)checkItem atIndexPath:(NSIndexPath *)indexPath inCheckList:(NSUInteger)checkListIndex
{
    LLCheckListSection *checkItemSection = (LLCheckListSection *)((LLCheckList *)self.arrayCheckLists[checkListIndex]).arraySections[indexPath.section];

    // 古いオブザーバーを削除する
    LLCheckItem *oldCheckItem = checkItemSection.checkItems[indexPath.row];
    if (oldCheckItem.keyValueObserver) {
        [oldCheckItem removeObserver:oldCheckItem.keyValueObserver forKeyPath:kKVOCheckedDate];
        DEBUGLOG(@"removeObserver IndexPath s=%d,r=%d", indexPath.section, indexPath.row);
    }
    oldCheckItem.keyValueObserver = nil;

    [checkItemSection.checkItems replaceObjectAtIndex:indexPath.row withObject:checkItem];
}

@end
