//
//  Message.h
//  Lesson 46 home
//
//  Created by Андрей on 27.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *senderID;

- (id) initWithServerResponse:(NSDictionary *) responseObject;

@end
