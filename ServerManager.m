//
//  ServerManager.m
//  Lesson 46 home
//
//  Created by Андрей on 24.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import "ServerManager.h"
#import "AFNetworking.h"
#import "AuthController.h"
#import "AccessToken.h"
#import "Post.h"
#import "User.h"
#import "Message.h"

@interface ServerManager ()

@property (strong, nonatomic) AFHTTPRequestOperationManager *requestOperationManager;
@property (strong, nonatomic) AccessToken *accessToken;

@end

@implementation ServerManager

+ (ServerManager *) sharedManager {
    
    static ServerManager *manager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [ServerManager new];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURL *url = [NSURL URLWithString:@"https://api.vk.com/method/"];
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    }
    return self;
}

- (void) authorizeUser:(void(^)(User *user)) completion {
    
    AuthController *authController = [[AuthController alloc] initWithCompletionBlock:^(AccessToken *accessToken) {
        self.accessToken = accessToken;
        
        [[ServerManager sharedManager] getUser:accessToken.userID onSuccess:^(User *user) {
            if (completion) {
                completion(user);
            }
        } onFailure:^(NSError *error, NSInteger statusCode) {
            NSLog(@"Error %@, Status Code %d", [error localizedDescription], statusCode);
        }];
    }];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:authController];
    
    [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:navController
                                                                                         animated:YES completion:nil];
}

- (void) getUser:(NSString *) userID
       onSuccess:(void(^)(User *user)) success
       onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *parameters = @{@"user_ids": userID, @"fields": @"photo_50", @"name_case": @"nom"};
    
    [self.requestOperationManager GET:@"users.get" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"JSON: %@", responseObject);
        
        NSArray *dictArray =  responseObject[@"response"];
        
        if ([dictArray count] > 0) {
            
            User *user = [[User alloc] initWithServerResponse:[dictArray firstObject]];
            
            if (success) {
                success(user);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            failure(error, operation.response.statusCode);
        }
    }];
}

- (void) getUserWithDat:(NSString *) userID
              onSuccess:(void(^)(NSString *firstName, NSString *lastName)) success
              onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *parameters = @{@"user_ids": userID, @"name_case": @"dat"};
    
    [self.requestOperationManager GET:@"users.get" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"JSON: %@", responseObject);
        
        NSArray *dictArray = responseObject[@"response"];
        
        NSDictionary *dict = [dictArray firstObject];
        
        NSString *firstName = dict[@"first_name"];
        NSString *lastName = dict[@"last_name"];
        
        if (success) {
            success(firstName, lastName);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            failure(error, operation.response.statusCode);
        }
    }];
}

- (void) getGroupWall:(NSString *) groupName
           withOffset:(NSInteger) offset
                count:(NSInteger) count
            onSuccess:(void(^)(NSArray *posts)) success
            onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *parameters = @{@"domain": groupName, @"count": @(count), @"offset": @(offset), @"filter": @"all",
                                 @"name_case": @"nom"};
    
    [self.requestOperationManager GET:@"wall.get" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"JSON: %@", responseObject);
        
        NSArray *dictsArray = responseObject[@"response"];
        
        if ([dictsArray count] > 1) {
            dictsArray = [dictsArray subarrayWithRange:NSMakeRange(1, (int)[dictsArray count] - 1)];
        } else {
            dictsArray = nil;
        }
        
        NSMutableArray *array = [NSMutableArray array];
        
        for (NSDictionary *dict in dictsArray) {
            Post *post = [[Post alloc] initWithServerResponse:dict];
            [array addObject:post];
        }
        
        if (success) {
            success(array);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            failure(error, operation.response.statusCode);
        }
    }];
}

- (void) postText:(NSString *) text
      onGroupWall:(NSString *) groupID
        onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *parameters = @{@"owner_id": groupID, @"message": text, @"access_token": self.accessToken.token};
    
    [self.requestOperationManager POST:@"wall.post" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"JSON: %@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            failure(error, operation.response.statusCode);
        }
    }];
}

- (void) postMessage:(NSString *) message
              toUser:(NSString *) userID
           onSuccess:(void(^)(void)) success
           onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *parameters = @{@"user_id": userID, @"message": message, @"access_token": self.accessToken.token};
    
    [self.requestOperationManager POST:@"messages.send" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success) {
            success();
        }
        
        //NSLog(@"JSON: %@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            failure(error, operation.response.statusCode);
        }
    }];
}

- (void) getMessagesWithOffset:(NSInteger) offset
                         count:(NSInteger) count
                     onSuccess:(void(^)(NSArray *messages)) success
                     onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    // out 0 - сервер вернет только входящие сообщения
    NSDictionary *parameters = @{@"out": @(0), @"count": @(count), @"offset": @(offset),
                                 @"access_token": self.accessToken.token};
    
    [self.requestOperationManager GET:@"messages.get" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        
        NSArray *dictsArray = responseObject[@"response"];

        if ([dictsArray count] > 1) {
            dictsArray = [dictsArray subarrayWithRange:NSMakeRange(1, (int)[dictsArray count] - 1)];
        } else {
            dictsArray = nil;
        }

        NSMutableArray *array = [NSMutableArray array];
        
        for (NSDictionary *dict in dictsArray) {
            Message *message = [[Message alloc] initWithServerResponse:dict];
            [array addObject:message];
        }
        
        if (success) {
            success(array);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            failure(error, operation.response.statusCode);
        }
    }];
}

- (void) getUploadServerForDownloadAlbum:(NSString *) albumID
                                   group:(NSString *) groupID
                               onSuccess:(void(^)(NSString *uploadURL)) success
                               onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *parameters = @{@"album_id": albumID, @"group_id": groupID, @"access_token": self.accessToken.token};
    
    [self.requestOperationManager GET:@"photos.getUploadServer" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dict = responseObject[@"response"];
        NSString *uploadURL = dict[@"upload_url"];
        
        if (success) {
            success(uploadURL);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            failure(error, operation.response.statusCode);
        }
    }];
}

- (void) postPhotoInGroup:(NSString *) groupID
                    album:(NSString *) albumID
                    photo:(UIImage *) image
                onSuccess:(void(^)(void)) success
                onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *parameters = @{@"group_id": groupID, @"album_id": albumID, @"access_token": self.accessToken.token};
    
    [self.requestOperationManager GET:@"photos.getUploadServer"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  
                                  //NSLog(@"%@", responseObject);
                                  
                                  NSDictionary *resultDict = responseObject[@"response"];
                                  NSString *resultURL = resultDict[@"upload_url"];
                                  NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
                                  
                                  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                                  manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
                                  
                                  [manager POST:resultURL parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                      
                                      [formData appendPartWithFileData:imageData name:@"file1" fileName:@"file1.png" mimeType:@"image/jpeg"];
                                      
                                  } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      
                                      //NSLog(@"%@", responseObject);
                                      
                                      NSString *server = responseObject[@"server"];
                                      NSString *hash = responseObject[@"hash"];
                                      NSString *photosList = responseObject[@"photos_list"];
                                      
                                      NSDictionary *parametersSave = @{@"group_id": groupID, @"album_id": albumID, @"server": server, @"hash": hash, @"photos_list": photosList, @"access_token": self.accessToken.token};
                                      
                                      [self.requestOperationManager GET:@"photos.save" parameters:parametersSave success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          //NSLog(@"%@", responseObject);
                                          
                                          if (success) {
                                              success();
                                          }
                                      } failure:nil];
                                      
                                  } failure:nil];
                              }
                              failure:nil];
}

@end
