//
//  WindowLocker.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import "WindowLocker.h"

static int loadingLockCount = 0;
static int lockCount = 0;
static UIView *loadingView = nil;

@interface WindowLocker ()
@property (nonatomic, assign) BOOL loading;
@end

@implementation WindowLocker

- (id)init
{
  CGRect bounds = [[UIScreen mainScreen] bounds];
  self = [super initWithFrame:bounds];
  if (self) {
    self.userInteractionEnabled = YES;
    [UIApplication.sharedApplication.keyWindow addSubview:self];
    ++lockCount;
  }
  return self;
}

- (void)close
{
  [self loadingClose];
  [self removeFromSuperview];
}

- (void)loadingClose
{
  if (!self.loading) return;
  self.loading = NO;
  if (--loadingLockCount == 0) {
    [UIView animateWithDuration:0.15f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                       loadingView.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                     }];
  }
}

+ (id)locker
{
  return [[[WindowLocker alloc] init] autorelease];
}

+ (id)loadingLocker
{
  CGRect bounds = [[UIScreen mainScreen] bounds];
  WindowLocker *locker = [WindowLocker locker];
  locker.loading = YES;
  
  if (!loadingView) {
    
    loadingView = [[[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds] autorelease];
   
    CGPoint center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f);
    
    UIView *back = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)] autorelease];
    back.center = center;
    back.alpha = 0.8f;
    back.backgroundColor = [UIColor blackColor];
    back.layer.cornerRadius = 5;
    back.clipsToBounds = true;
    [loadingView addSubview:back];
    
    UIActivityIndicatorView *indicator = [[[UIActivityIndicatorView alloc]
                                           initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    indicator.center = center;
    [indicator startAnimating];
    [loadingView addSubview:indicator];
    
    [UIApplication.sharedApplication.keyWindow addSubview:loadingView];
  }
  
  ++loadingLockCount;
  if (loadingLockCount == 1) {
    loadingView.alpha = 0.0f;
    [UIView animateWithDuration:0.15f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ loadingView.alpha = 1.0f; }
                     completion:^(BOOL finished) {}];
  }
  
  return locker;
}

@end
