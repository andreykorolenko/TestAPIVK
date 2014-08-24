//
//  PostCell.h
//  Lesson 46 home
//
//  Created by Андрей on 24.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SendMessageButton;

@interface PostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *postTextlabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet SendMessageButton *sendMessageButton;
@property (weak, nonatomic) IBOutlet UITextView *postTextView;

+ (CGFloat) heightForText:(NSString *) text;

@end
