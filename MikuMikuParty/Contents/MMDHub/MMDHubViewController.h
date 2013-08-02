//
//  MMDHubViewController.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/13.
//
//

#import <UIKit/UIKit.h>
#import "MMDHubItemTableView.h"
#import "MMDHubController.h"

@interface MMDHubViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) IBOutlet UIView *loginView;
@property (nonatomic, assign) IBOutlet MMDHubItemTableView *tableView;
@property (nonatomic, retain) MMDHubController *hubController;

- (IBAction)twitterLoginButtonDidPush:(id)sender;

@end
