//
//  Post.h
//  Lesson 46 home
//
//  Created by Андрей on 24.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *ownerID;
@property (strong, nonatomic) NSDate *datePost;
@property (assign, nonatomic) NSInteger likesCount;
@property (assign, nonatomic) NSInteger commentsCount;

- (id) initWithServerResponse:(NSDictionary *) responseObject;

@end
