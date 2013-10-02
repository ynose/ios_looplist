//
//  LLCheckItem.m
//  Looplist
//
//  Created by Yoshio Nose on 2013/07/09.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLCheckItem.h"

@implementation LLCheckItem

-(id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }

    self.caption = nil;
    self.checkedDate = nil;
    self.memo = nil;
    self.colorLabelIndex = 0;

    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }

    self.caption = [aDecoder decodeObjectForKey:@"caption"];
    self.checkedDate = [aDecoder decodeObjectForKey:@"checkedDate"];
    self.memo = [aDecoder decodeObjectForKey:@"memo"];
    self.colorLabelIndex = [aDecoder decodeIntegerForKey:@"colorLabelIndex"];

    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.caption forKey:@"caption"];
    [aCoder encodeObject:self.checkedDate forKey:@"checkedDate"];
    [aCoder encodeObject:self.memo forKey:@"memo"];
    [aCoder encodeInteger:self.colorLabelIndex forKey:@"colorLabelIndex"];
}

-(id)copyWithZone:(NSZone *)zone
{
    LLCheckItem *clone = [[[self class] allocWithZone:zone] init];
    clone.caption = [self caption];
    clone.checkedDate = [self checkedDate];
    clone.memo = [self memo];
    clone.colorLabelIndex = [self colorLabelIndex];

    return clone;
}

// チェック完了処理
-(void)complete
{
    // チェック完了時にリセットする項目
    self.checkedDate = nil;
}

-(BOOL)hasDetail
{
    return (self.memo.length > 0);
}

@end
