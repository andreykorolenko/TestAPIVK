//
//  SendMessageButton.h
//  Lesson 46 home
//
//  Created by Андрей on 25.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface SendMessageButton : UIButton

@property (strong, nonatomic) User *user;

@end
