//
//  SendMessageController.h
//  Lesson 46 home
//
//  Created by Андрей on 25.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface SendMessageController : UIViewController

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSString *userID;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UITextField *messageField;

- (IBAction)cancelSendMessageAction:(UIBarButtonItem *)sender;
- (IBAction)sendMessageAction:(UIButton *)sender;

@end
