//
//  PartyViewController.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/14.
//
//

#import "PartyViewController.h"
#import "ItemSelectViewController.h"
#import "AppDelegate.h"
#import "ES2Renderer.h"

@interface PartyViewController ()

@end

@implementation PartyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"Party";
  }
  return self;
}

- (void)dealloc
{
  self.modelFilename = nil;
  self.motionFilename = nil;
  [super dealloc];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectModelButtonDidPush:(id)sender
{
  NSArray *modelArray = [self modelArray];
  ItemSelectViewController *controller = [ItemSelectViewController controllerWithModelArray:modelArray];
  
  __block PartyViewController *weakSelf = self;
  controller.handler = ^(NSString *selectedItem){
    weakSelf.modelFilename = selectedItem;
    weakSelf.modelNameLabel.text = [[selectedItem lastPathComponent] stringByDeletingPathExtension];
  };
  
  [self presentModalViewController:controller animated:YES];
}

- (IBAction)selectMotionButtonDidPush:(id)sender
{
  NSArray *motionArray = [self motionArray];
  ItemSelectViewController *controller = [ItemSelectViewController controllerWithMotionArray:motionArray];

  __block PartyViewController *weakSelf = self;
  controller.handler = ^(NSString *selectedItem){
    weakSelf.motionFilename = selectedItem;
    weakSelf.motionNameLabel.text = [[selectedItem lastPathComponent] stringByDeletingPathExtension];
  };
  
  [self presentModalViewController:controller animated:YES];
}

- (IBAction)partyButtonDidPush:(id)sender
{
  if (self.modelFilename == nil) return;
  if (self.motionFilename == nil) return;
  
  AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
  [delegate.navigationController popToRootViewControllerAnimated:YES];
  [delegate.glView.renderer load:self.modelFilename motion:self.motionFilename];
  [delegate.glView startAnimation];
}

- (NSArray*)modelArray
{
  NSMutableArray *modelArray = [NSMutableArray array];
  
  NSString* path=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	path = [path stringByAppendingPathComponent:@"Downloads"];
  
  NSString *filename = nil;
  NSDictionary *attrs = nil;
  NSDirectoryEnumerator* dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:path];
  [dirEnum skipDescendants];
  while (filename = [dirEnum nextObject]) {
    attrs = [dirEnum fileAttributes];
    if ([[attrs objectForKey:NSFileType] isEqualToString:NSFileTypeRegular]) {
      NSString *extension = [[filename pathExtension] lowercaseString];
      if ([extension isEqualToString:@"pmd"]) [modelArray addObject:[path stringByAppendingPathComponent:filename]];
      if ([extension isEqualToString:@"pmx"]) [modelArray addObject:[path stringByAppendingPathComponent:filename]];
    }
  }
  
  NSLog(@"modelArray = %@", modelArray);
  
  return [NSArray arrayWithArray:modelArray];
}

- (NSArray*)motionArray
{
  NSMutableArray *motionArray = [NSMutableArray array];
  
  NSString* path=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	path=[path stringByAppendingPathComponent:@"Downloads"];
  
  NSString *filename = nil;
  NSDictionary *attrs = nil;
  NSDirectoryEnumerator* dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:path];
  [dirEnum skipDescendants];
  while (filename = [dirEnum nextObject]) {
    attrs = [dirEnum fileAttributes];
    if ([[attrs objectForKey:NSFileType] isEqualToString:NSFileTypeRegular]) {
      NSString *extension = [[filename pathExtension] lowercaseString];
      if ([extension isEqualToString:@"vmd"]) [motionArray addObject:[path stringByAppendingPathComponent:filename]];
    }
  }
  
  NSLog(@"motionArray = %@", motionArray);
  
  return [NSArray arrayWithArray:motionArray];
}

@end
