//
//  AuthController.h
//  Lesson 46 home
//
//  Created by Андрей on 24.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccessToken.h"

typedef void(^AuthCompletionBlock)(AccessToken *accessToken);

@interface AuthController : UIViewController

- (id) initWithCompletionBlock:(AuthCompletionBlock) completion;

@end
