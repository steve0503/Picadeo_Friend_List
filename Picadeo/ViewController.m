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
    
    cell.textLabel.text = [one objectForKey:@"name"];
    
    return cell;
    
    
}



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
