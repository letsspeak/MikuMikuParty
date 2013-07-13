//
//  MikuMikuError.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/13.
//
//

#import "MikuMikuError.h"

@implementation MikuMikuError

NSString *const MikuMikuErrorDomain = @"MikuMikuErrorDomain";

- (id)initWithErrorCode:(NSInteger)code
{
  NSDictionary *userInfo = [MikuMikuError userInfoWithCode:code];
  self = [self initWithDomain:MikuMikuErrorDomain
                         code:code
                     userInfo:userInfo];
  if (self) {
    self.message = nil;
    self.action = nil;
  }
  return self;
}

+ (id)errorWithCode:(NSInteger)code
{
  return [[[MikuMikuError alloc] initWithErrorCode:code] autorelease];
}

+ (NSDictionary*)userInfoWithCode:(NSInteger)code
{
  NSDictionary *descriptionDictionary = [self descriptionDictionaryWithCode:code];
  
  NSString *localizedDescription = [descriptionDictionary objectForKey:@"localizedDescription"];
  NSString *localizedFailureReasonError = [descriptionDictionary objectForKey:@"localizedFailureReasonError"];
  NSString *LocalizedRecoverySuggestionError = [descriptionDictionary objectForKey:@"LocalizedRecoverySuggestionError"];
  
  NSDictionary *userInfo= [NSDictionary dictionaryWithObjectsAndKeys:
                           localizedDescription, NSLocalizedDescriptionKey,
                           localizedFailureReasonError, NSLocalizedFailureReasonErrorKey,
                           LocalizedRecoverySuggestionError,
                           NSLocalizedRecoverySuggestionErrorKey, nil];
  return userInfo;
}

+ (NSDictionary*)descriptionDictionaryWithCode:(NSInteger)code
{
  NSString *path = [[NSBundle mainBundle] pathForResource:@"MikuMikuErrorDescriptions" ofType:@"plist"];
  NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
  
  for (NSDictionary *descriptionDictionary in dictionary.allValues) {
    if ([[descriptionDictionary objectForKey:@"code"] intValue] == code) return descriptionDictionary;
  }
  
  return nil;
}


@end
