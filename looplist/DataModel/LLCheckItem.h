//
//  LLCheckItem.h
//  Looplist
//
//  Created by Yoshio Nose on 2013/07/09.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLCheckItem : NSObject <NSCoding, NSCopying>

// データ部
@property (copy, nonatomic) NSString *caption;
@property (copy, nonatomic) NSDate *checkedDate;
@property (copy, nonatomic) NSString *memo;
@property (assign, nonatomic) NSInteger colorLabelIndex;

-(void)complete;
-(BOOL)hasDetail;

@end
