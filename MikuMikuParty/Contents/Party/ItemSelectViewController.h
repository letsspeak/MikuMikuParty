//
//  ItemSelectViewController.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/18.
//
//

#import <UIKit/UIKit.h>

@interface ItemSelectViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSArray *items;
@property (nonatomic, copy) void(^handler)(NSString *selectedItem);

+ (id)controllerWithModelArray:(NSArray*)modelArray;
+ (id)controllerWithMotionArray:(NSArray*)motionArray;

@end
