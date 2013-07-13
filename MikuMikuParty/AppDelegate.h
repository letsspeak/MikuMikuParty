//
//  AppDelegate.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/11.
//
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"
#import "PickerViewController.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarDelegate>
{
	IBOutlet UITabBar *_tabBar;
	IBOutlet UIViewController* _viewCtrl;
	PickerViewController* _pickerViewCtrl;
	NSMutableArray* _motionFiles;
	NSMutableArray* _modelFiles;
	
	NSString* _strModelFile;
	NSString* _strMotionFile;
	int32_t _iPickerMode;
	int32_t _iCurrentSelection[ 2 ];
  
  

}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (nonatomic, retain) EAGLView *glView;
@property (nonatomic, assign) UINavigationController *navigationController;

@property (nonatomic, retain) NSMutableArray* motionFiles;
@property (nonatomic, retain) NSMutableArray* modelFiles;

- (void) hideModal:(UIView*) modalView;
- (NSArray*) getPickerItems;
- (void) picked:(int32_t)iIndex;
- (int32_t) getSelection;

@end
