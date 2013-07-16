//
//  ItemDetailViewController.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/15.
//
//

#import <UIKit/UIKit.h>
#import "MMDHubItem.h"

@interface ItemDetailViewController : UIViewController

@property (nonatomic, assign) MMDHubItem *item;

@property (nonatomic, assign) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) IBOutlet UILabel *categoryLabel;
@property (nonatomic, assign) IBOutlet UILabel *filenameLabel;
@property (nonatomic, assign) IBOutlet UILabel *sizeLabel;
@property (nonatomic, assign) IBOutlet UILabel *digestLabel;
@property (nonatomic, assign) IBOutlet UILabel *isPublicLabel;
@property (nonatomic, assign) IBOutlet UIButton *downloadButton;

- (IBAction)downloadButtonDidPush:(id)sender;

+ (id)controllerWithItem:(MMDHubItem*)item;

@end
