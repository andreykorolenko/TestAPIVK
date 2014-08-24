//
//  MessagesController.m
//  Lesson 46 home
//
//  Created by Андрей on 27.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import "MessagesController.h"
#import "ServerManager.h"
#import "SendMessageController.h"

#import "User.h"
#import "Message.h"

@interface MessagesController ()

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *users;

@end

@implementation MessagesController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.users = [NSMutableArray array];
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(refreshMessages) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [self getMessages];
}

#pragma mark - Actions

- (void) refreshMessages {
    
    [[ServerManager sharedManager] getMessagesWithOffset:0 count:20 onSuccess:^(NSArray *messages) {
        self.messages = [NSMutableArray arrayWithArray:messages];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    } onFailure:nil];
}

#pragma mark - API

- (void) getMessages {
    
    [[ServerManager sharedManager] getMessagesWithOffset:0 count:20 onSuccess:^(NSArray *messages) {
        self.messages = [NSMutableArray arrayWithArray:messages];
        [self.tableView reloadData];
    } onFailure:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    Message *message = [self.messages objectAtIndex:indexPath.row];
    
    [[ServerManager sharedManager] getUser:message.senderID onSuccess:^(User *user) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
        [self.users addObject:user];
    } onFailure:nil];
    
    cell.textLabel.text = message.text;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Message *message = [self.messages objectAtIndex:indexPath.row];
    
    [[ServerManager sharedManager] getUser:message.senderID onSuccess:^(User *user) {
        
        UIViewController *vc = [self.navigationController.viewControllers firstObject];
        
        SendMessageController *smController = [vc.storyboard instantiateViewControllerWithIdentifier:@"SendMessageController"];
        smController.user = user;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:smController];
        
        [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:navController
                                                                                             animated:YES completion:nil];
        
    } onFailure:nil];
}

@end
