//
//  ELcolorLabelButton.h
//  Looplist
//
//  Created by Yoshio Nose on 2013/08/30.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "UIGlossyButton.h"

@interface LLColorLabelButton : UIGlossyButton

@property (assign, nonatomic) NSInteger colorLabelIndex;
@property (copy, nonatomic) NSString *caption;

@end
