//
//  Post.m
//  Lesson 46 home
//
//  Created by Андрей on 24.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import "Post.h"

@implementation Post

- (id) initWithServerResponse:(NSDictionary *) responseObject
{
    self = [super init];
    if (self) {
        self.text = responseObject[@"text"];
        self.text = [self.text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
        
        NSNumber *ownerID = responseObject[@"from_id"];
        self.ownerID = [ownerID stringValue];
        
        NSDictionary *likesDict = responseObject[@"likes"];
        NSNumber *likes = likesDict[@"count"];
        self.likesCount = [likes integerValue];
        
        NSDictionary *commentsDict = responseObject[@"comments"];
        NSNumber *comments = commentsDict[@"count"];
        self.commentsCount = [comments integerValue];
        
        NSNumber *datePost = responseObject[@"date"];
        NSTimeInterval interval = [datePost doubleValue];
        self.datePost = [NSDate dateWithTimeIntervalSince1970:interval];
    }
    return self;
}

@end
