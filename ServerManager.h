//
//  ServerManager.h
//  Lesson 46 home
//
//  Created by Андрей on 24.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@class UIImage;

@interface ServerManager : NSObject

@property (strong, nonatomic, readonly) User *currentUser;

+ (ServerManager *) sharedManager;

// Авторизует пользователя
- (void) authorizeUser:(void(^)(User *user)) completion;

// Возвращает расширенную информацию о пользователе
- (void) getUser:(NSString *) userID
       onSuccess:(void(^)(User *user)) success
       onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// Возвращает имя и фамилию пользователя в дательном падеже
- (void) getUserWithDat:(NSString *) userID
              onSuccess:(void(^)(NSString *firstName, NSString *lastName)) success
              onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// Возвращает список записей со стены сообщества
- (void) getGroupWall:(NSString *) groupName
           withOffset:(NSInteger) offset
                count:(NSInteger) count
            onSuccess:(void(^)(NSArray *posts)) success
            onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// Публикует новую запись на своей или чужой стене
- (void) postText:(NSString *) text
      onGroupWall:(NSString *) groupName
        onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// Отправляет сообщение
- (void) postMessage:(NSString *) message
              toUser:(NSString *) userID
           onSuccess:(void(^)(void)) success
           onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// Возвращает список входящих либо исходящих личных сообщений текущего пользователя
- (void) getMessagesWithOffset:(NSInteger) offset
                         count:(NSInteger) count
                     onSuccess:(void(^)(NSArray *messages)) success
                     onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// Возвращает адрес сервера для загрузки фотографий
- (void) getUploadServerForDownloadAlbum:(NSString *) albumID
                                   group:(NSString *) groupID
                               onSuccess:(void(^)(NSString *uploadURL)) success
                               onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// Загружает фото в альбом группы
- (void) postPhotoInGroup:(NSString *) groupID
                    album:(NSString *) albumID
                    photo:(UIImage *) image
                onSuccess:(void(^)(void)) success
                onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;
@end
