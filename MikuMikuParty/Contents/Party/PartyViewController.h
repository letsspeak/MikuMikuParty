//
//  PartyViewController.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/14.
//
//

#import <UIKit/UIKit.h>

@interface PartyViewController : UIViewController

@property (nonatomic, retain) NSString *modelFilename;
@property (nonatomic, retain) NSString *motionFilename;

@property (nonatomic, assign) IBOutlet UILabel *modelNameLabel;
@property (nonatomic, assign) IBOutlet UILabel *motionNameLabel;
@property (nonatomic, assign) IBOutlet UIButton *partyButton;

- (IBAction)selectModelButtonDidPush:(id)sender;
- (IBAction)selectMotionButtonDidPush:(id)sender;
- (IBAction)partyButtonDidPush:(id)sender;

@end
