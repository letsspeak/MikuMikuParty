//
//  TwitterAccountSelector.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/08/03.
//
//

#import "TwitterAccountSelector.h"

@interface TwitterAccountSelector ()

@property (nonatomic, retain) NSArray *accounts;
@property (nonatomic, copy) void(^selectedHandler)(ACAccount *account);
@property (nonatomic, copy) void(^cancelHandler)(void);

@property (nonatomic, assign) UITableView *tableView;

@end

@implementation TwitterAccountSelector

static NSString *TwitterAccountSelectorCellIdentifier = @"TwitterAccountSelectorCellIdentifier";


- (id)initWithAccounts:(NSArray*)accounts
       selectedHandler:(void(^)(ACAccount *account))selectedHandler
         cancelHandler:(void(^)(void))cancelHandler
{
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    
    self.accounts = accounts;
    self.selectedHandler = selectedHandler;
    self.cancelHandler = cancelHandler;
    
    CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
    
    CGFloat barHeight = 44.0f;
    CGRect barFrame = CGRectMake(0, 0, applicationFrame.size.width, barHeight);
    UINavigationBar *bar = [[[UINavigationBar alloc] initWithFrame:barFrame] autorelease];
    bar.barStyle = UIBarStyleDefault;
    
    UINavigationItem *titleItem = [[[UINavigationItem alloc] initWithTitle:@"Twitterアカウント選択"] autorelease];
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
  self.accounts = nil;
  self.selectedHandler = nil;
  self.cancelHandler = nil;
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
  void(^_ch)(void) = [[self.cancelHandler copy] autorelease];
  [self dismissViewControllerAnimated:YES completion:^{
    if (_ch) _ch();
  }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TwitterAccountSelectorCellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc]
             initWithStyle:UITableViewCellStyleSubtitle
             reuseIdentifier:TwitterAccountSelectorCellIdentifier] autorelease];
  }
  
  ACAccount *account = self.accounts[indexPath.row];
  cell.textLabel.text = [NSString stringWithFormat:@"@%@", account.username];
  cell.textLabel.adjustsFontSizeToFitWidth = YES;
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  void(^_sh)(ACAccount *account) = [[self.selectedHandler copy] autorelease];
  [self dismissViewControllerAnimated:YES completion:^{
    if (_sh) _sh(self.accounts[indexPath.row]);
  }];
}

#pragma mark - + methods

+ (id)selectorWithAccounts:(NSArray*)accounts
           selectedHandler:(void(^)(ACAccount *account))selectedHandler
             cancelHandler:(void(^)(void))cancelHandler
{
  return [[[TwitterAccountSelector alloc] initWithAccounts:accounts
                                           selectedHandler:selectedHandler
                                             cancelHandler:cancelHandler] autorelease];
}

@end