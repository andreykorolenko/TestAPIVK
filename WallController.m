//
//  WallController.m
//  Lesson 46 home
//
//  Created by Андрей on 24.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import "WallController.h"
#import "AuthController.h"
#import "SendMessageController.h"
#import "MessagesController.h"
#import "ServerManager.h"
#import "UIImageView+AFNetworking.h"
#import "PostCell.h"
#import "LikesCell.h"
#import "SendMessageButton.h"
#import "Post.h"
#import "User.h"

@interface WallController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSMutableArray *postsArray;
@property (assign, nonatomic) BOOL firstTime;
@property (assign, nonatomic) NSInteger count;
@property (strong, nonatomic) User *authorizedUser;

@end

@implementation WallController

static NSInteger postsInRequest = 20;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.postsArray = [NSMutableArray array];
    self.firstTime = YES;
    self.count = 0;
    
    [self getWallFromServer];
    
    // pull to refresh
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshWall) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    UIBarButtonItem *downloadPhoto = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                             target:self
                                                                             action:@selector(downloadPhoto:)];
    
    UIBarButtonItem *myMessages = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Messages"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(myMessagesShow:)];
    self.navigationItem.leftBarButtonItem = downloadPhoto;
    self.navigationItem.rightBarButtonItem = myMessages;
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (self.firstTime) {
        self.firstTime = NO;
        [[ServerManager sharedManager] authorizeUser:^(User *user) {
            self.authorizedUser = user;
        }];
    }
}

#pragma mark - Actions

- (void) downloadPhoto:(id) sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void) myMessagesShow:(UIBarButtonItem *) sender {
    
    MessagesController *messagesController = [[MessagesController alloc] init];
    [self.navigationController pushViewController:messagesController animated:YES];
}

- (void) refreshWall {
    
    [[ServerManager sharedManager]
     getGroupWall:@"rfygttrfty" withOffset:0 count:MAX(postsInRequest, [self.postsArray count]) onSuccess:^(NSArray *posts) {
         
         [self.postsArray removeAllObjects];
         [self.postsArray addObjectsFromArray:posts];
         
         [self.tableView reloadData];
         [self.refreshControl endRefreshing];
         
     } onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"Error %@, Code %d", [error localizedDescription], statusCode);
         [self.refreshControl endRefreshing];
     }];
    
}

- (IBAction)sendMessageAction:(SendMessageButton *)sender {
    
    SendMessageController *smController = [self.storyboard instantiateViewControllerWithIdentifier:@"SendMessageController"];
    smController.user = sender.user;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:smController];
    
    [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:navController
                                                                                         animated:YES completion:nil];
}

#pragma mark - API

- (void) getWallFromServer {
    
    [[ServerManager sharedManager]
     getGroupWall:@"rfygttrfty" withOffset:[self.postsArray count] count:postsInRequest onSuccess:^(NSArray *posts) {
         
         [self.postsArray addObjectsFromArray:posts];
         
         NSMutableArray *newPath = [NSMutableArray new];
         for (int i = [self.postsArray count] - [posts count]; i < [self.postsArray count] * 2; i++) {
             [newPath addObject:[NSIndexPath indexPathForRow:i inSection:0]];
         }
         
         [self.tableView reloadData];
         
     } onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"Error %@, Code %d", [error localizedDescription], statusCode);
     }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.postsArray count] * 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row % 2 == 0) {
        
        PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
        
        Post *post = [self.postsArray objectAtIndex:indexPath.row - indexPath.row / 2];
        
        [[ServerManager sharedManager] getUser:post.ownerID onSuccess:^(User *user) {
            cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
            cell.sendMessageButton.user = user;
            cell.postTextView.text = post.text;
            //cell.postTextlabel.text = post.text;
            
            __weak PostCell *weakCell = cell;
            
            NSURLRequest *request = [NSURLRequest requestWithURL:user.imageURL];
            
            cell.userImage.image = nil;
            
            [cell.userImage setImageWithURLRequest:request placeholderImage:nil
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               weakCell.userImage.image = image;
                                               [weakCell layoutSubviews];
                                           } failure:nil];

        } onFailure:nil];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"dd-MM-YY HH:mm"];
        cell.dateLabel.text = [dateFormatter stringFromDate:post.datePost];
        
        return cell;
        
    } else {
        
        LikesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LikesCell"];
        
        Post *post = [self.postsArray objectAtIndex:indexPath.row - (indexPath.row / 2) - 1];
        
        cell.likesLabel.text = [NSString stringWithFormat:@"Лайки: %d", post.likesCount];
        cell.commentsLabel.text = [NSString stringWithFormat:@"Комментарии: %d", post.commentsCount];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row % 2 == 0) {
        
        Post *post = [self.postsArray objectAtIndex:indexPath.row - indexPath.row / 2];
        return [PostCell heightForText:post.text] + 50;
        
    } else {
        return 24.f;
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    
    [[ServerManager sharedManager] postPhotoInGroup:@"74687185" album:@"199550734" photo:image onSuccess:^{
        
        [[[UIAlertView alloc] initWithTitle:@"Уведомление" message:@"Фотография успешно загружена" delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles:nil] show];
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"Error %@, Code %d", [error localizedDescription], statusCode);
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
