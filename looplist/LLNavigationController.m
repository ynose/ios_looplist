//
//  LLNavigationController.m
//  looplist
//
//  Created by Yoshio Nose on 2013/10/01.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLNavigationController.h"
#import "LLNavigationBar.h"

@interface LLNavigationController ()

@end

@implementation LLNavigationController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithNavigationBarClass:[LLNavigationBar class] toolbarClass:nil];
    if(self) {
        // Custom initialization here, if needed.
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithNavigationBarClass:[LLNavigationBar class] toolbarClass:nil];
    if(self) {
        self.viewControllers = @[rootViewController];
    }

    return self;
}

@end
