//
//  AppDelegate.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/11.
//
//

#import "AppDelegate.h"
#import "EAGLView.h"
#import "pmdReader.h"
#import "ES2Renderer.h"

#import "ViewController.h"
#import "MMDHubViewController.h"
#import "DownloadsViewController.h"
#import "PartyViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.viewController = [[ViewController alloc] initWithNibName:nil bundle:nil];
  self.viewController.wantsFullScreenLayout = YES;
  
  self.glView = [[EAGLView alloc] initWithFrame:[self.window bounds]];
  [self.viewController setView:self.glView];
  
  self.navigationController = [[[UINavigationController alloc] initWithRootViewController:self.viewController] autorelease];
  self.navigationController.navigationBarHidden = YES;
  
  [self.window setRootViewController:self.navigationController];
  [self.window makeKeyAndVisible];
  
  ///////
 
  MMDHubViewController *mmdhub = [[[MMDHubViewController alloc] initWithNibName:@"MMDHubViewController" bundle:nil] autorelease];
  UINavigationController *mmdhubNav = [[[UINavigationController alloc] initWithRootViewController:mmdhub] autorelease];

  DownloadsViewController *downloads = [[[DownloadsViewController alloc] initWithNibName:@"DownloadsViewController" bundle:nil] autorelease];
  UINavigationController *downloadsNav = [[[UINavigationController alloc] initWithRootViewController:downloads] autorelease];
  
  PartyViewController *party = [[[PartyViewController alloc] initWithNibName:@"PartyViewController" bundle:nil] autorelease];
  UINavigationController *partyNav = [[[UINavigationController alloc] initWithRootViewController:party] autorelease];
  
  self.tabBarController = [[UITabBarController alloc] init];
  self.tabBarController.viewControllers = @[mmdhubNav, downloadsNav, partyNav];
  self.tabBarController.view.backgroundColor = [UIColor yellowColor];
 
  [self.navigationController pushViewController:self.tabBarController animated:NO];

	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  [self.glView stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  [self.glView startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  [self.glView stopAnimation];
}

- (void)dealloc
{
  self.window = nil;
  self.glView = nil;
  
  [super dealloc];
}

@end
