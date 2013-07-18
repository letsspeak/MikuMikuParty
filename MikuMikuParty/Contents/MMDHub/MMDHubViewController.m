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

@implementation MMDHubViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"MMDHub";
//    self.tabBarItem.image = [UIImage imageNamed:@"first"];
  }
  return self;
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.tableView.parentViewController = self;
  
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
  
//  NSString* path=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//	path=[path stringByAppendingPathComponent:@"Downloads"];
//  
//  NSString *filename = nil;
//  NSDictionary *attrs = nil;
//  NSDirectoryEnumerator* dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:path];
//  [dirEnum skipDescendants];
//  while (filename = [dirEnum nextObject]) {
//    attrs = [dirEnum fileAttributes];
//    NSLog(@"filename: %@", filename);
//    NSLog(@"attrs = %@", attrs);
//
//  }
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


@end
