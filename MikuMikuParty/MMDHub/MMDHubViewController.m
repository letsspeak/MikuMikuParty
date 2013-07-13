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

@interface MMDHubViewController ()

@end

@implementation MMDHubViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  MikuMikuRequest *request = [MikuMikuRequest requestWithController:@"items" action:@"user_items"];
  request.method = MikuMikuRequestMethodHttpGet;
  [WindowLocker lockWithRequest:request
               succeededHandler:
   ^(MikuMikuResponse *response){
     
     NSLog(@"response.responses = %@", response.responses);
     
   }
                  failedHandler:
   ^(MikuMikuError *error){
     
     NSLog(@"items/user_items failed with error:¥n%@", error);
     
   }];
  
//  if (TwitterController.defaultTwitterAccount) {
//    
//  }else {
//    [TwitterController getTwitterAccount];
//  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
