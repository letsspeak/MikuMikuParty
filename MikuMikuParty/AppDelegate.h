//
//  AppDelegate.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/11.
//
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (nonatomic, retain) EAGLView *glView;

@property (nonatomic, assign) UINavigationController *navigationController;
@property (nonatomic, retain) UITabBarController *tabBarController;

@end
