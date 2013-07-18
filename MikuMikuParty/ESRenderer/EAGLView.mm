//
//  EAGLView.m
//  MikuMikuPhone
//
//  Created by hakuroum on 1/14/11.
//  Copyright 2011 hakuroum@gmail.com . All rights reserved.
//

#import "EAGLView.h"
#import "ES2Renderer.h"
#import "AppDelegate.h"

@interface EAGLView ()
@property (nonatomic, getter=isAnimating) BOOL animating;
@end


@implementation EAGLView

@synthesize animating, animationFrameInterval, displayLink, animationTimer, renderer;

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Get the layer
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking : [NSNumber numberWithBool:FALSE],
                                      kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
    
    renderer = [[ES2Renderer alloc] init];

    if (!renderer) {
      [self release];
      return nil;
    }
    
    animating = NO;
    displayLinkSupported = NO;
    animationFrameInterval = 1;
    displayLink = nil;
    animationTimer = nil;
    
    // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
    // class is used as fallback when it isn't available.
    NSString *reqSysVer = @"3.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
      displayLinkSupported = YES;
    
    UIButton *stopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    stopButton.titleLabel.text = @"x";
    stopButton.titleLabel.textColor = [UIColor blackColor];
    stopButton.frame = CGRectMake(4, 24, 30, 30);
    [stopButton addTarget:self action:@selector(stopButtonDidPush:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:stopButton];
  }
  
  return self;
}

- (void)dealloc
{
  [renderer release];
  [displayLink release];
  
  [super dealloc];
}

- (void)drawView:(id)sender
{
  [renderer render];
}

- (void)layoutSubviews
{
  [renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
  [self drawView:nil];
}

- (NSInteger)animationFrameInterval
{
  return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
  // Frame interval defines how many display frames must pass between each time the
  // display link fires. The display link will only fire 30 times a second when the
  // frame internal is two on a display that refreshes 60 times a second. The default
  // frame interval setting of one will fire 60 times a second when the display refreshes
  // at 60 times a second. A frame interval setting of less than one results in undefined
  // behavior.
  if (frameInterval >= 1) {
    animationFrameInterval = frameInterval;
    
    if (animating) {
      [self stopAnimation];
      [self startAnimation];
    }
  }
}

- (void)startAnimation
{
  if (!animating) {
    
    if (displayLinkSupported) {
      
      // CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
      // if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
      // not be called in system versions earlier than 3.1.
      
      self.displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView:)];
      [displayLink setFrameInterval:animationFrameInterval];
      [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
      
    } else {
      self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval)
                                                             target:self selector:@selector(drawView:)
                                                           userInfo:nil repeats:TRUE];
    }
    
    self.animating = YES;
  }
}

- (void)stopAnimation
{
  if (animating) {
    
    if (displayLinkSupported) {
      [displayLink invalidate];
      self.displayLink = nil;
    } else {
      [animationTimer invalidate];
      self.animationTimer = nil;
    }
    
    self.animating = NO;
  }
}

- (void)stopButtonDidPush:(id)sender
{
  [self stopAnimation];

  AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
  [delegate.navigationController pushViewController:delegate.tabBarController animated:YES];
}


@end
