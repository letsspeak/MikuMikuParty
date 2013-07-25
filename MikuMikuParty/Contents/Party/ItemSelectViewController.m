//
//  ItemSelectViewController.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/18.
//
//

#import "ItemSelectViewController.h"

@interface ItemSelectViewController ()

@property (nonatomic, assign) UITableView *tableView;
@end

@implementation ItemSelectViewController

static NSString *ItemSelectViewControllerCellIdentifier = @"ItemSelectViewControllerCellIdentifier";

- (id)initWithTitle:(NSString*)title items:(NSArray*)items
{
  NSLog(@"items = %@", items);
  self = [super initWithNibName:nil bundle:nil];
  if (self) {

    self.items = items;
    self.handler = nil;
    
    CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
    
    CGFloat barHeight = 44.0f;
    CGRect barFrame = CGRectMake(0, 0, applicationFrame.size.width, barHeight);
    UINavigationBar *bar = [[[UINavigationBar alloc] initWithFrame:barFrame] autorelease];
    bar.barStyle = UIBarStyleDefault;
    
    UINavigationItem *titleItem = [[[UINavigationItem alloc] initWithTitle:title] autorelease];
    titleItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(cancelButtonDidPush:)] autorelease];
    NSArray *items = @[titleItem];
    [bar setItems:items animated:NO];
    
    [self.view addSubview:bar];
   
    CGRect tableFrame = CGRectMake(0, barHeight, applicationFrame.size.width, applicationFrame.size.height - barHeight);
    self.tableView = [[[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain] autorelease];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
  }
  return self;
}

- (void)dealloc
{
  self.items = nil;
  [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelButtonDidPush:(id)sender
{
  NSLog(@"ItemSelectViewController::cancelButtonDidPush:");
  [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableViewDataSource

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//  return 0;
//}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//  int category = section + 1;
//  return [MMDHubItem nameWithCategory:category];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ItemSelectViewControllerCellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc]
             initWithStyle:UITableViewCellStyleSubtitle
             reuseIdentifier:ItemSelectViewControllerCellIdentifier] autorelease];
  }
  
  // for debug
  if ([[self.items[indexPath.row] pathExtension] isEqualToString:@"pmx"]) {
    cell.textLabel.textColor = [UIColor grayColor];
  } else {
    cell.textLabel.textColor = [UIColor blackColor];
  }
      
  cell.textLabel.text = [[self.items[indexPath.row] lastPathComponent] stringByDeletingPathExtension];
  cell.textLabel.adjustsFontSizeToFitWidth = YES;
//  cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y,
//                          cell.frame.size.width, cell.frame.size.height + 20);
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  //  NSDictionary *item = [self itemWithIndexPath:indexPath];
  //  int category = [item[@"category"] integerValue];
  //  if (category == ITEM_CATEGORY_MMD_MODEL) return 100;
  //  if (category == ITEM_CATEGORY_MMD_MOTION) return 100;
  return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  if (self.handler) {
    self.handler(self.items[indexPath.row]);
  }

  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - + methods

+ (id)controllerWithModelArray:(NSArray*)modelArray
{
  ItemSelectViewController *controller = [[[ItemSelectViewController alloc] initWithTitle:@"モデル選択" items:modelArray] autorelease];
  return controller;
}

+ (id)controllerWithMotionArray:(NSArray*)motionArray
{
  ItemSelectViewController *controller = [[[ItemSelectViewController alloc] initWithTitle:@"モーション選択" items:motionArray] autorelease];
  return controller;
}

@end
