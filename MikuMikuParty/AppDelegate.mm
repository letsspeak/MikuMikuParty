//
//  AppDelegate.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/11.
//
//

#import "AppDelegate.h"
#import "PickerViewController.h"
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

- (void)loadDefaultModels
{
  
  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* doc = [paths objectAtIndex:0];
	NSFileManager* fm = [NSFileManager defaultManager];
	
	NSArray* files = [fm contentsOfDirectoryAtPath:doc error:nil];
	
	if( _motionFiles == nil )
		_motionFiles = [[NSMutableArray alloc] init];
	if( _modelFiles == nil )
		_modelFiles = [[NSMutableArray alloc] init];
	
	[_modelFiles removeAllObjects];
	[_motionFiles removeAllObjects];
	
	for( NSString* file in files )
	{
		if( [[file lowercaseString] hasSuffix:@".pmd" ])
		{
			[_modelFiles addObject:file];
		}
		else if( [[file lowercaseString] hasSuffix:@".vmd" ])
		{
			[_motionFiles addObject:file];
		}
	}
	
	_strModelFile = @"AnimalCrossingNewLeaf_Isabelle.pmd";//@"初音ミクVer2.pmd";
	_strMotionFile = @"kpm1-miku.vmd"; //@"恋VOCALOID.vmd";
	_iCurrentSelection[ 0 ] = -1;
	_iCurrentSelection[ 1 ] = -1;
	
	//		NSString* strFile = [[NSBundle mainBundle] pathForResource:@"初音ミク" ofType:@"pmd"];
	for( int32_t i = 0; i < [_modelFiles count]; ++i )
	{
		if( [_strModelFile compare:[_modelFiles objectAtIndex:i]] == 0 )
		{
			_iCurrentSelection[ 0 ] = i;
			break;
		}
	}
	for( int32_t i = 0; i < [_motionFiles count]; ++i )
	{
		if( [_strMotionFile compare:[_motionFiles objectAtIndex:i]] == 0 )
		{
			_iCurrentSelection[ 1 ] = i;
			break;
		}
	}
	
  //	[self picked:_iCurrentSelection[ _iPickerMode ]];
  
  
  NSString* strFile = nil;
	if( _strModelFile )
	{
		strFile = [NSString stringWithFormat:@"%@/%@", doc, _strModelFile];
	}
	NSString* strMotionFile = nil;
	if( _strMotionFile )
	{
		strMotionFile = [NSString stringWithFormat:@"%@/%@", doc, _strMotionFile];
	}
  
  NSLog(@"strFile = %@", strFile);
  NSLog(@"strMotionFile = %@", strMotionFile);
  [self.glView.renderer load:strFile motion:strMotionFile];
  
	//	[glView.renderer load:strFile motion:strMotionFile];
  
  [self.glView startAnimation];
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
	[_pickerViewCtrl release];
  self.window = nil;
  self.glView = nil;
	[_modelFiles release];
	[_motionFiles release];
  
  [super dealloc];
}

#pragma mark tabBar
- (void) showModal:(UIView*) modalView
{
  CGSize offSize = [UIScreen mainScreen].bounds.size;
	CGPoint middleCenter = CGPointMake( offSize.width / 2,
                                     offSize.height - modalView.bounds.size.height / 2 );
	
  CGPoint offScreenCenter = CGPointMake(offSize.width / 2.0,
                                        offSize.height + modalView.bounds.size.height / 2);
  modalView.center = offScreenCenter;
	
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.5]; // animation duration in seconds
  modalView.center = middleCenter;
  [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
  if ([finished boolValue])
	{
    [_pickerViewCtrl.view removeFromSuperview];
		[self.glView startAnimation];
	}
}

- (void) hideModal:(UIView*) modalView
{
  CGSize offSize = [UIScreen mainScreen].bounds.size;
  CGPoint offScreenCenter = CGPointMake(offSize.width / 2.0,
                                        offSize.height + modalView.bounds.size.height / 2);
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.5]; // animation duration in seconds
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationDelegate:self];
  
  modalView.center = offScreenCenter;
  [UIView commitAnimations];
}


- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
	_iPickerMode = item.tag;
  
  [self.glView stopAnimation];
	
	if( _pickerViewCtrl != nil )
		[_pickerViewCtrl release];
	
	_pickerViewCtrl = [[PickerViewController alloc] init];
	[self.glView addSubview:_pickerViewCtrl.view];
	[_pickerViewCtrl.view sizeToFit];
	
	[self showModal:_pickerViewCtrl.view];
}

- (NSArray*) getPickerItems
{
	switch (_iPickerMode)
	{
		case 0:
			return _modelFiles;
		default:
			return _motionFiles;
	}
}

- (void) picked:(int32_t)i
{
	if( i >= 0 )
	{
		switch (_iPickerMode)
		{
			case 0:
				_strModelFile = [_modelFiles objectAtIndex:i ];
				break;
			default:
				_strMotionFile = [_motionFiles objectAtIndex:i ];
				break;
		}
		_iCurrentSelection[ _iPickerMode ] = i;
	}
  
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* doc = [paths objectAtIndex:0];
  
	//NSFileManager* fm = [NSFileManager defaultManager];
	//NSArray* files = [fm contentsOfDirectoryAtPath:doc error:nil];
	
	
	//		NSString* strFile = [[NSBundle mainBundle] pathForResource:@"初音ミク" ofType:@"pmd"];
	NSString* strFile = nil;
	if( _strModelFile )
	{
		strFile = [NSString stringWithFormat:@"%@/%@", doc, _strModelFile];
	}
	NSString* strMotionFile = nil;
	if( _strMotionFile )
	{
		strMotionFile = [NSString stringWithFormat:@"%@/%@", doc, _strMotionFile];
	}
  
  NSLog(@"strFile = %@", strFile);
  NSLog(@"strMotionFile = %@", strMotionFile);
  
//  [self.glView.renderer load:strFile motion:strMotionFile];
}

- (int32_t) getSelection
{
	return _iCurrentSelection[ _iPickerMode ];
}

@end
