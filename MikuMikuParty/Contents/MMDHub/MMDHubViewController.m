//
//  MMDHubViewController.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/13.
//
//

#import "MMDHubViewController.h"
#import "MikuMikuConnection.h"
#import "WindowLocker+MikuMikuConnection.h"
#import "TwitterController.h"

@implementation MMDHubViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"MMDHub";
//    self.tabBarItem.image = [UIImage imageNamed:@"first"];
    UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                           target:self action:@selector(refreshButtonDidPush:)] autorelease];
    self.navigationItem.rightBarButtonItem = item;
  }
  return self;
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.tableView.parentViewController = self;
//  [self loadUserItems];
}

- (void)loadUserItems
{
  MikuMikuRequest *request = [MikuMikuRequest requestWithController:@"items" action:@"user_items"];
  request.method = MikuMikuRequestMethodHttpGet;
  [WindowLocker lockWithRequest:request
               succeededHandler:
   ^(MikuMikuResponse *response){
     
     NSLog(@"response.responses = %@", response.responses);
     [self.tableView setItemCollection:[MMDHubItemCollection collectionWithItemDics:response[@"items"]]];
   }
                  failedHandler:
   ^(MikuMikuError *error){
     
     NSLog(@"items/user_items failed with error:¥n%@", error);
     
   }];
}

- (void)loadItems:(NSArray*)items
{
  
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

- (void)refreshButtonDidPush:(id)sender
{
  [self loadUserItems];
}

- (IBAction)twitterLoginButtonDidPush:(id)sender
{
  __block UIButton *button = (UIButton*)sender;
  button.enabled = NO;
  [TwitterController getTwitterAccountWithUsername:nil
                                  succeededHandler:^(ACAccount *account)
  {
    NSLog(@"succeed");
    NSLog(@"account.username = %@", account.username);
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"];
    TWRequest *twRequest = [[[TWRequest alloc] initWithURL:url parameters:nil requestMethod:TWRequestMethodGET] autorelease];
    [twRequest setAccount:account];
    
    NSURLRequest *signedURLRequest = [twRequest signedURLRequest];
    
    // X-Auth-Service-Provider
    NSString *serviceProvider = [[signedURLRequest URL] absoluteString];
    NSLog(@"X-Auth-Service-Provider=%@", serviceProvider );
    
    
    // X-Verify-Credentials-Authorization
    NSString *authorization = [signedURLRequest valueForHTTPHeaderField:@"Authorization"];
    NSLog(@"X-Verify-Credentials-Authorization=%@", authorization );
    
    button.enabled = YES;
    [TwitterController deleteInstance];
  }
  
                                           failedHandler:^(void)
  {
    NSLog(@"failed");
    button.enabled = YES;
    [TwitterController deleteInstance];
  } parentViewController:self];
}

@end
