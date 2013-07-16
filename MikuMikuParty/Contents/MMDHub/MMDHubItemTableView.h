//
//  MMDHubItemTableView.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/14.
//
//

#import <UIKit/UIKit.h>
#import "MMDHubItemCollection.h"

#define ITEM_CATEGORY_MMD_MODEL       5
#define ITEM_CATEGORY_MMD_MOTION      7

@interface MMDHubItemTableView : UITableView
<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) MMDHubItemCollection *itemCollection;
@property (nonatomic, assign) UIViewController *parentViewController;

@end
