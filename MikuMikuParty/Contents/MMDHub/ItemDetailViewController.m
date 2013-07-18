//
//  ItemDetailViewController.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/15.
//
//

#import "ItemDetailViewController.h"
#import "DownloadController.h"

@interface ItemDetailViewController ()

@end

@implementation ItemDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"詳細データ";
    self.item = nil;
  }
  return self;
}

- (id)initWithItem:(MMDHubItem*)item
{
  self = [self initWithNibName:@"ItemDetailViewController" bundle:nil];
  if (self) {
    self.item = item;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.titleLabel.text = self.item.title;
  self.categoryLabel.text = [MMDHubItem nameWithCategory:self.item.category];
  self.filenameLabel.text = self.item.filename;
  self.sizeLabel.text = [MMDHubItem stringWithSize:self.item.size];
  self.digestLabel.text = [NSString stringWithFormat:@"ハッシュ値:%@",self.item.digest];
  self.isPublicLabel.text = self.item.isPublic ? @"公開" : @"非公開";
  
  if (self.item.category == MMDHubItemCategoryMMDModel
      || self.item.category == MMDHubItemCategoryMMDMotion) {
    self.downloadButton.hidden = NO;
    self.downloadButton.enabled = YES;
  } else {
    self.downloadButton.hidden = YES;
    self.downloadButton.enabled = NO;
  }
  
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)downloadButtonDidPush:(id)sender
{
  NSLog(@"ItemDetailViewController::downloadButtonDidPush");
  [[DownloadController sharedController] downloadItem:self.item];
}

+ (id)controllerWithItem:(MMDHubItem*)item
{
  return [[[self alloc] initWithItem:item] autorelease];
}

@end
