//
//  SendMessageController.m
//  Lesson 46 home
//
//  Created by Андрей on 25.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import "SendMessageController.h"
#import "ServerManager.h"
#import "User.h"

@interface SendMessageController () <UITextFieldDelegate>

@end

@implementation SendMessageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[ServerManager sharedManager] getUserWithDat:self.user.userID onSuccess:^(NSString *firstName, NSString *lastName) {
        self.senderLabel.text = [NSString stringWithFormat:@"Кому: %@ %@", firstName, lastName];
    } onFailure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"Error %@, Code %d", [error localizedDescription], statusCode);
    }];
}

- (IBAction)cancelSendMessageAction:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendMessageAction:(UIButton *)sender {
    
    if ([self.messageField isFirstResponder]) {
        [self.messageField resignFirstResponder];
    }
    
    [[ServerManager sharedManager] postMessage:self.messageField.text toUser:self.user.userID onSuccess:^{
        
        [[[UIAlertView alloc] initWithTitle:@"Уведомление" message:@"Сообщение отправлено" delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles:nil] show];
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"Error %@, Code %d", [error localizedDescription], statusCode);
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([self.messageField isFirstResponder]) {
        [self.messageField resignFirstResponder];
    }
    
    [self sendMessageAction:nil];
    return YES;
}

@end
