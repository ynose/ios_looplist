//
//  LLCheckListManager.h
//  Looplist
//
//  Created by Yoshio Nose on 2013/07/09.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLCheckListSection.h"
#import "LLCheckList.h"
#import "LLCheckItem.h"


@class LLCheckList;
@interface LLCheckListManager : NSObject
@property (strong) NSMutableArray *arrayCheckLists;     // LLCheckListの配列　checkLists[]sections[]checkItems[]

+(LLCheckListManager *)sharedManager;

// チェックリストファイル
-(void)loadCheckLists;
-(void)saveCheckLists;
#ifdef APPSTORE_SCREENSHOT
-(void)loadScreenshotCheckLists;
#endif

// 画像ファイル
-(void)saveAttachImage:(UIImage *)image fileName:(NSString *)fileName;
-(void)removeAttachImageFile:(NSString *)fileName;
-(UIImage *)loadAttachImage:(NSString *)fileName;
-(NSString *)existsAttachImageFile:(NSString *)fileName;

-(void)insertObject:(LLCheckList *)checkList inCheckList:(NSUInteger)checkListIndex;
-(NSInteger)addObject:(LLCheckList *)checkList;
-(void)removeCheckList:(NSInteger)checkListIndex;
-(void)replaceCheckList:(NSUInteger)checkListIndex withObject:(LLCheckList *)checkList;

-(void)completeCheckList:(NSUInteger)checkListIndex;

-(NSURL *)URLForCheckListFile;
-(NSURL *)URLForCheckListDirectory;
-(NSURL *)URLForCheckListFileAtFileName:(NSString* )fileName;

-(NSString *)dir;
@end


// チェックアイテム
@class LLCheckItem;
@interface LLCheckListManager (CheckItem)
-(void)loadCheckItems;
-(void)saveCheckItems;
-(void)saveCheckItemsInCheckList:(NSInteger)checkListIndex;
-(void)disposeGarbageFilesAtURL:(NSArray *)oldFileURLs;

-(NSIndexPath *)addCheckItem:(LLCheckItem *)checkItem section:(NSInteger)section inCheckList:(NSUInteger)checkListIndex;
-(void)insertCheckItem:(LLCheckItem *)checkItem atIndexPath:(NSIndexPath *)indexPath inCheckList:(NSUInteger)checkListIndex;
-(void)removeCheckItem:(LLCheckItem *)checkItem inCheckList:(NSUInteger)checkListIndex;
-(void)moveCheckItem:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath inCheckList:(NSUInteger)checkListIndex;

-(void)replaceCheckItem:(LLCheckItem *)checkItem atIndexPath:(NSIndexPath *)indexPath inCheckList:(NSUInteger)checkListIndex;
@end