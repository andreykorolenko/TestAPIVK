//
//  Message.m
//  Lesson 46 home
//
//  Created by Андрей on 27.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import "Message.h"
#import "ServerManager.h"
#import "User.h"

@implementation Message

- (id) initWithServerResponse:(NSDictionary *) responseObject
{
    self = [super init];
    if (self) {
        self.text = responseObject[@"body"];
        self.senderID = responseObject[@"uid"];
    }
    return self;
}


@end
