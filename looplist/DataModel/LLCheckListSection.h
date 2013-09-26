//
//  LLCheckListSection.h
//  EverList
//
//  Created by Yoshio Nose on 2013/08/29.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLCheckListSection : NSObject <NSCoding, NSCopying>

@property (copy, nonatomic) NSString *caption;
@property (strong, nonatomic) NSMutableArray *checkItems;


-(id)initWithCaption:(NSString *)caption checkItems:(NSMutableArray *)checkItems;

@end
