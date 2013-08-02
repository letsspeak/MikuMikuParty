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
#import "AppDelegate.h"

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
    self.hubController = [MMDHubController new];
  }
  return self;
}

- (void)dealloc
{
  self.hubController = nil;
  [super dealloc];
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
  
  __block MMDHubController *hubController = self.hubController;
  __block MMDHubViewController *weakSelf = self;
  
  [TwitterController getTwitterAccount:nil
                      succeededHandler:^(ACAccount *account)
  {
    [hubController createUserWithTwitterAccount:account
                               succeededHandler:^(void){
                                 weakSelf.loginView.hidden = YES;
                                 [weakSelf loadUserItems];
                               }
                                  failedHandler:^(void){}];
    button.enabled = YES;
    [TwitterController deleteInstance];
  }
  
                                           failedHandler:^(void)
  {
    button.enabled = YES;
    [TwitterController deleteInstance];
  } parentViewController:self];
}



@end
