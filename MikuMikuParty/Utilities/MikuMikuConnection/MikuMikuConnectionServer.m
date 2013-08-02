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
    
    if (request.urlPrameterString) {
      url = [url stringByAppendingFormat:@"/%@", request.urlPrameterString];
    }
    
    NSString *parameterString = [self urlEncodedParameterStringWithDictionary:request.parameters];
    if (parameterString) url = [url stringByAppendingFormat:@"?%@", parameterString];
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

#pragma mark - for http api format

- (NSString*)currentHttpApiFormat
{
  if (_currentServerDictionary == nil) return nil;
  return [self httpApiUrlFormatWithServerDictionary:_currentServerDictionary];
}

- (NSString*)currentHttpsApiFormat
{
  if (_currentServerDictionary == nil) return nil;
  return [self httpsApiUrlFormatWithServerDictionary:_currentServerDictionary];
}

#pragma mark - for delete cookies

- (void)deleteCookie:(NSString*)name
{
  NSLog(@"SmartConnectionServer deleteCookie %@ called.", name);
  
  NSString *httpHost = [self hostWithApiFormat:[self currentHttpApiFormat]];
  NSLog(@"httpHost = %@", httpHost);
  [self deleteCookie:name forHost:[NSString stringWithFormat:@"http://%@",httpHost]];
  
  NSString *httpsHost = [self hostWithApiFormat:[self currentHttpsApiFormat]];
  NSLog(@"httpsHost = %@", httpsHost);
  [self deleteCookie:name forHost:[NSString stringWithFormat:@"https://%@",httpsHost]];
}

- (void)deleteCookie:(NSString*)name forHost:(NSString*)host
{
  if (name == nil) return;
  if (host == nil) return;
  
  NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
  NSArray *cookies = [storage cookiesForURL:[NSURL URLWithString:host]];
  
  for (NSHTTPCookie *cookie in cookies) {
    if ([name isEqualToString:cookie.name]){
      [storage deleteCookie: cookie];
    }
  }
}

- (void)deleteAllCookies
{
  NSString *httpHost = [self hostWithApiFormat:[self currentHttpApiFormat]];
  NSLog(@"httpHost = %@", httpHost);
  [self deleteAllCookiesForHost:[NSString stringWithFormat:@"http://%@",httpHost]];
  
  NSString *httpsHost = [self hostWithApiFormat:[self currentHttpsApiFormat]];
  NSLog(@"httpsHost = %@", httpsHost);
  [self deleteAllCookiesForHost:[NSString stringWithFormat:@"https://%@",httpsHost]];
}

- (void)deleteAllCookiesForHost:(NSString*)host
{
  if (host == nil) return;
  
  NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
  NSArray *cookies = [storage cookiesForURL:[NSURL URLWithString:host]];
  
  for (NSHTTPCookie *cookie in cookies) {
    [storage deleteCookie: cookie];
  }
}

- (NSString*)hostWithApiFormat:(NSString*)apiFormat
{
  NSString *pattern = @"(.+)://(.+?)/(.+)";
  
  NSError *error = nil;
  NSRegularExpression *regexp =
  [NSRegularExpression regularExpressionWithPattern:pattern
                                            options:0
                                              error:&error];
  if (error) return nil;
  
  NSTextCheckingResult *result =
  [regexp firstMatchInString:apiFormat options:0 range:NSMakeRange(0, apiFormat.length)];
  
  if (result.numberOfRanges != 4) return nil;
  
//  // for debug
//  for (int i = 0; i < result.numberOfRanges; i++) {
//    NSString *match = [apiFormat substringWithRange:[result rangeAtIndex:i]];
//    NSLog(@"match = %@", match);
//  }
  
  return [apiFormat substringWithRange:[result rangeAtIndex:2]];
}


@end