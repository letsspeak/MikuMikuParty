//
//  MikuMikuConnectionServer.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/13.
//
//

#import "MikuMikuConnectionServer.h"

@interface MikuMikuConnectionServer ()
@property (nonatomic, retain) NSString *defaultServerName;
@property (nonatomic, retain) NSArray *serverDictionaryArray;
@property (nonatomic ,retain) NSDictionary *currentServerDictionary;
@end

@implementation MikuMikuConnectionServer


#pragma mark - singleton managements

static MikuMikuConnectionServer *_sharedInstance = nil;

+ (MikuMikuConnectionServer*)sharedServer
{
  @synchronized (self) {
    if (_sharedInstance == nil) {
      _sharedInstance = [[self alloc] init];
    }
  }
  return _sharedInstance;
}

+ (id)allocWithZone:(NSZone*)zone
{
  @synchronized(self){
    if(_sharedInstance == nil){
      _sharedInstance = [super allocWithZone:zone];
      return _sharedInstance;
    }
  }
  return nil;
}

+ (id)copyWithZone:(NSZone*)zone
{
  return self;
}

+ (void)deleteInstance
{
  if (_sharedInstance) {
    @synchronized(_sharedInstance) {
      _sharedInstance = nil;
    }
  }
}

- (id)retain
{
  return self;
}

- (unsigned)retainCount
{
  return UINT_MAX;
}

- (oneway void)release
{
  // never release
}

- (id)autorelease
{
  return self;
}

#pragma mark - methods

- (id)init
{
  self = [super init];
  if (self) {
    [self loadServers];
  }
  return self;
}

- (void)dealloc
{
  self.defaultServerName = nil;
  self.serverDictionaryArray = nil;
  self.currentServerDictionary = nil;
  [super dealloc];
}

- (void)loadServers
{
  NSString *path = [[NSBundle mainBundle] pathForResource:@"MikuMikuConnectionServers" ofType:@"plist"];
  NSDictionary *serversDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
  
  self.defaultServerName = [serversDictionary objectForKey:@"defaultServerName"];
  self.serverDictionaryArray = [serversDictionary objectForKey:@"servers"];
  self.currentServerDictionary = [self serverDictionaryWithServerName:self.defaultServerName];
}

- (NSDictionary*)serverDictionaryWithServerName:(NSString*)serverName
{
  for (NSDictionary *dictionary in self.serverDictionaryArray) {
    if ([dictionary[@"name"] isEqualToString:serverName]) return dictionary;
  }
  return nil;
}

- (NSString*)generateUriWithRequest:(MikuMikuRequest*)request
{
  NSString *controller = request.controller;
  NSString *action = request.action;
  NSString *urlFormat = [self urlFormatWithServerDictionary:self.currentServerDictionary
                                                 controller:controller
                                                     action:action];
  NSString *url = [self generateUriWithUrlFormat:urlFormat controller:controller action:action];

  if (request.method == MikuMikuRequestMethodHttpGet) {
    NSString *parameterString = [self urlEncodedParameterStringWithDictionary:request.parameters];
    if (parameterString) [url stringByAppendingFormat:@"?%@", parameterString];
  }
  
  return url;
}

- (NSString*)urlFormatWithServerDictionary:(NSDictionary*)serverDictionary
                                controller:(NSString*)controller
                                    action:(NSString*)action
{
  NSString *apiKey = [NSString stringWithFormat:@"%@/%@", controller, action];
  NSDictionary *optionsDictionary = [serverDictionary objectForKey:@"options"];
  NSDictionary *useSSLSettingDictionary = [optionsDictionary objectForKey:@"useSSLSetting"];
  
  BOOL useSSL = NO;
  if ([useSSLSettingDictionary.allKeys containsObject:apiKey]){
    NSNumber *settingNumber = [useSSLSettingDictionary objectForKey:apiKey];
    useSSL = [settingNumber boolValue];
  }
  
  if (useSSL == YES) return [self httpsApiUrlFormatWithServerDictionary:serverDictionary];
  return [self httpApiUrlFormatWithServerDictionary:serverDictionary];
}

- (NSString*)httpApiUrlFormatWithServerDictionary:(NSDictionary*)serverDictionary
{
  NSDictionary *urlsDictionary = [serverDictionary objectForKey:@"urls"];
  return [urlsDictionary objectForKey:@"httpApi"];
}

- (NSString*)httpsApiUrlFormatWithServerDictionary:(NSDictionary*)serverDictionary
{
  NSDictionary *urlsDictionary = [serverDictionary objectForKey:@"urls"];
  return [urlsDictionary objectForKey:@"httpsApi"];
}

- (NSString*)generateUriWithUrlFormat:(NSString*)urlFormat
                           controller:(NSString*)controller
                               action:(NSString*)action
{
  NSString *uri = [urlFormat stringByReplacingOccurrencesOfString:@"<controller>" withString:controller];
  uri = [uri stringByReplacingOccurrencesOfString:@"<action>" withString:action];
  return uri;
}

- (NSString*)urlEncodedParameterStringWithDictionary:(NSDictionary*)parameterDictionary
{
  // Arrays and dictionaries are not supported
  NSMutableArray *parameterStringArray = [NSMutableArray array];
  for (NSString *key in parameterDictionary.allKeys) {
    
    id value = [parameterDictionary objectForKey:key];
    
    if ([value isKindOfClass:[NSString class]]){
      NSString *valueString = (NSString*)value;
      [parameterStringArray addObject:[NSString stringWithFormat:@"%@=%@", key, valueString]];
      continue;
    }
    
    if ([value isKindOfClass:[NSNumber class]]){
      NSNumber *numValue = value;
      [parameterStringArray addObject:
       [NSString stringWithFormat:@"%@=%@", key, (strcmp(numValue.objCType, @encode(BOOL)) == 0) ? (numValue.boolValue ? @"true" : @"false") : numValue.stringValue]];
      continue;
    }
  }
  
  NSString *parameterString = [parameterStringArray componentsJoinedByString:@"&"];
  return [parameterString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSDictionary*)httpHeaderFieldDictionary
{
  NSDictionary *optionsDictionary = [self.currentServerDictionary objectForKey:@"options"];
  if ([optionsDictionary.allKeys containsObject:@"httpHeaderFieldSetting"] == NO){
    return [NSDictionary dictionary];
  }
  // add your httpHeaderFieldSetting rules
  return [optionsDictionary objectForKey:@"httpHeaderFieldSetting"];
}

@end