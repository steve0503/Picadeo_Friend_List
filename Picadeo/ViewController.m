//
//  ViewController.m
//  Picadeo
//
//  Created by SDT-1 on 2014. 1. 21..
//  Copyright (c) 2014년 steve. All rights reserved.
//

#import "ViewController.h"

#import <Social/Social.h>

#import  <Accounts/Accounts.h>

#define FACEBOOK_APPID @"496860960433765"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) ACAccount *facebookAccount;

@property (strong, nonatomic) NSArray *data;

@property (strong, nonatomic) IBOutlet UITableView *table;

@end

@implementation ViewController


-(void)showTimeline{
    
    
    ACAccountStore *store = [[ACAccountStore alloc]init];
    
    ACAccountType *accountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSDictionary *options = @{ACFacebookAppIdKey:FACEBOOK_APPID,ACFacebookPermissionsKey:@[@"user_friends"],ACFacebookAudienceKey:ACFacebookAudienceEveryone};
    
    [store requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted,NSError *error){
        
        if (error) {
            NSLog(@"Error: %@",error);
        }
        
        
        if (granted) {
            NSLog(@"권한 승인 성공");
            
            NSArray *accountList = [store accountsWithAccountType:accountType];
            
            self.facebookAccount = [accountList lastObject];
            
            [self requestFeed];
        }
        else{
            
            
            NSLog(@"권한 승인 실패");
            
            
            
        }
        
        
    }];
    
    

    
}

-(void)requestFeed{
    
    
    NSString *urlStr = @"https://graph.facebook.com/me/friends";
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSDictionary *params = nil;
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:url parameters:params];
    
    request.account = self.facebookAccount;
    
    [request performRequestWithHandler:^(NSData *responseData,NSHTTPURLResponse *urlResponse,NSError *error){
        
        if (nil != error) {
            NSLog(@"Error: %@",error);
            return;
        }
        
        
        
        __autoreleasing NSError *parseError;
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&parseError];
        
        
        self.data = result[@"data"];
        
        //메인 쓰레드에서 화면 업데이트
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [self.table reloadData];
            
        }];
        
    }];
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.data count];
    
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FRIENDS_CELL"];
    
    NSDictionary *one = self.data[indexPath.row];
    
    
    NSString *contents;
    
#if 0
    if (one[@"message"]) {
        
        
        NSDictionary *likes = one[@"likes"];
        
        NSArray *data = likes[@"data"];
        
        contents = [NSString stringWithFormat:@"%@ ....(%d)",one[@"message"],[data count]];
    }
    else{
        
        
        contents = one[@"story"];
        
        cell.indentationLevel = 2;
        
        
    
    }
    
#endif

    
    
    
    
    cell.textLabel.text = [one objectForKey:@"name"];
    
    return cell;
    
    
}

#if 0
FBRequest* friendsRequest = [FBRequest requestWithGraphPath:@"me/friends?fields=installed" parameters:nil HTTPMethod:@"GET"];
[friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                              NSDictionary* result,
                                              NSError *error) {
    NSArray* friends = [result objectForKey:@"data"];
    NSLog(@"Found: %i friends", friends.count);
    for (NSDictionary<FBGraphUser>* friend in friends) {
        NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
        
    }
    NSArray *friendIDs = [friends collect:^id(NSDictionary<FBGraphUser>* friend) {
        return friend.id;
    }];
    
}];


#endif


#if 0

- (void)request:(FBRequest *)request didLoad:(id)result {
    //ok so it's a dictionary with one element (key="data"), which is an array of dictionaries, each with "name" and "id" keys
    items = [[(NSDictionary *)result objectForKey:@"data"]retain];
    for (int i=0; i<[items count]; i++) {
        NSDictionary *friend = [items objectAtIndex:i];
        long long fbid = [[friend objectForKey:@"id"]longLongValue];
        NSString *name = [friend objectForKey:@"name"];
        NSLog(@"id: %lld - Name: %@", fbid, name);
    }
}

#endif


-(void)viewWillAppear:(BOOL)animated{
    
    
    [self showTimeline];
    
}




- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
