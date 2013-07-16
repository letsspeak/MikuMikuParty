//
//  MMDHubViewController.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/13.
//
//

#import <UIKit/UIKit.h>
#import "MMDHubItemTableView.h"

@interface MMDHubViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) IBOutlet MMDHubItemTableView *tableView;

@end
