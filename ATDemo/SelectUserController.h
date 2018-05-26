//
//  SelectUserController.h
//  ATDemo
//
//  Created by lisong on 2018/5/25.
//  Copyright © 2018年 lisong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectUserBlock)(NSString *name);

@interface SelectUserController : UIViewController

@property (nonatomic, copy) SelectUserBlock selectBlock;

@end
