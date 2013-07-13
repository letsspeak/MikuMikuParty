//
//  MikuMikuRequest.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/13.
//
//

#import "MikuMikuRequest.h"
#import "MikuMikuRequestPerformer.h"

@implementation MikuMikuRequest

- (id)initWithController:(NSString*)controller action:(NSString*)action
{
  self = [super init];
  if (self){
    self.controller = controller;
    self.action = action;
  }
  return self;
}

- (void)dealloc
{
  self.controller = nil;
  self.action = nil;
  self.succeededHandler = nil;
  self.failedHandler = nil;
  [super dealloc];
}

- (void)performRequestWithSucceededHandler:(void(^)(MikuMikuResponse *response))succeededHandler
                             failedHandler:(void(^)(MikuMikuError *error))failedHandler
{
  self.succeededHandler = succeededHandler;
  self.failedHandler = failedHandler;
  [[MikuMikuRequestPerformer sharedPerformer] performRequest:self];
}


+ (id)requestWithController:(NSString*)controller action:(NSString*)action
{
  return [[[MikuMikuRequest alloc] initWithController:controller action:action] autorelease];
}

@end
