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
    if ([jsonDictionary.allKeys containsObject:@"args"]) {
      self.responses = [NSMutableDictionary dictionaryWithDictionary:jsonDictionary[@"args"]];
    }
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

- (id)objectForKeyedSubscript:(id)key
{
  return [self.responses objectForKey:key];
}

- (void)setObject:(id)object forKeyedSubscript:(id)key
{
  return [self.responses setObject:object forKey:key];
}

+ (id)responseWithJsonDictionary:(NSDictionary*)jsonDictionary request:(MikuMikuRequest*)request
{
  return [[[MikuMikuResponse alloc] initWithJsonDictionary:jsonDictionary request:request] autorelease];
}

@end
