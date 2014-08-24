//
//  User.m
//  Lesson 46 home
//
//  Created by Андрей on 24.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import "User.h"

@implementation User

- (id) initWithServerResponse:(NSDictionary *) responseObject
{
    self = [super init];
    if (self) {
        NSNumber *userID = responseObject[@"uid"];
        self.userID = [userID stringValue];
        
        self.firstName = responseObject[@"first_name"];
        self.lastName = responseObject[@"last_name"];
        
        NSString *urlString = responseObject[@"photo_50"];
        self.imageURL = [NSURL URLWithString:urlString];
    }
    return self;
}

@end
