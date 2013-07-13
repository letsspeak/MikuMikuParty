//
//  MikuMikuResponse.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/13.
//
//

#import "MikuMikuResponse.h"

@implementation MikuMikuResponse

- (id)initWithJsonDictionary:(NSDictionary*)jsonDictionary request:(MikuMikuRequest*)request
{
  self = [super init];
  if (self) {
    self.responses = jsonDictionary;
    self.request = request;
  }
  return self;
}

- (void)dealloc
{
  self.responses = nil;
  self.request = nil;
  [super dealloc];
}

+ (id)responseWithJsonDictionary:(NSDictionary*)jsonDictionary request:(MikuMikuRequest*)request
{
  return [[[MikuMikuResponse alloc] initWithJsonDictionary:jsonDictionary request:request] autorelease];
}

@end
