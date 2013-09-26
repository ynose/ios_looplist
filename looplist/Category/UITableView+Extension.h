//
//  UITableView+Extension.h
//  Looplist
//
//  Created by Yoshio Nose on 2013/07/23.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (Extension)

//-(void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
-(void)deleteRowsAtIndexPaths:(NSArray *)indexPaths duration:(NSTimeInterval)duration withRowAnimation:(UITableViewRowAnimation)animation completion:(void (^)(BOOL finished))completion;

-(void)deselectSelectedRow:(BOOL)animated;
//-(void)scrollToEndRowAtScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

-(void)reloadDataAfterDelay:(NSTimeInterval)delay;
-(void)reloadVisibleRowsAfterDelay:(NSTimeInterval)delay withRowAnimation:(UITableViewRowAnimation)animation;

@end
