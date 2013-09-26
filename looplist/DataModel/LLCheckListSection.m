//
//  LLCheckListSection.m
//  Looplist
//
//  Created by Yoshio Nose on 2013/08/29.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLCheckListSection.h"

@implementation LLCheckListSection

-(id)init
{
    self = [super init];
    if (self) {
        self.checkItems = [NSMutableArray array];
    }

    return self;
}

-(id)initWithCaption:(NSString *)caption checkItems:(NSMutableArray *)checkItems
{
    self = [super init];
    if (self) {
        self.caption = caption;
        self.checkItems = checkItems;
    }

    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithCaption:[aDecoder decodeObjectForKey:@"caption"]
                      checkItems:[aDecoder decodeObjectForKey:@"checkItems"]];
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.caption forKey:@"caption"];
    [aCoder encodeObject:self.checkItems forKey:@"checkItems"];
}

-(id)copyWithZone:(NSZone *)zone
{
    LLCheckListSection *clone = [[[self class] allocWithZone:zone] init];
    clone.caption = [self caption];
    clone.checkItems = [self checkItems];

    return clone;
}

@end
