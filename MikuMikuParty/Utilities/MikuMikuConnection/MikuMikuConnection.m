//
//  MikuMikuConnection.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/13.
//
//

#import "MikuMikuConnection.h"
#import "MikuMikuConnectionServer.h"

@interface MikuMikuConnection ()
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, assign) NSTimer *timeoutTimer;
@property (nonatomic, assign) BOOL didReceiveResponse;
@property (nonatomic, assign) BOOL didTimeOut;
@end

@implementation MikuMikuConnection

- (id)initWithRequest:(MikuMikuRequest*)request delegate:(id<MikuMikuConnectionDelegate>)delegate
{
  self = [super init];
  if (self) {
    self.delegate = delegate;
    [self loadRequest:request];
  }
  return self;
}

- (void)dealloc
{
  self.responseData = nil;
  [super dealloc];
}

- (void)loadRequest:(MikuMikuRequest*)request
{
  NSLog(@"MikuMikuConnection::loadRequest");
  NSLog(@"request = %@", request);
  
  self.request = request;
  if (request.method == MikuMikuRequestMethodUndefined) {
    [self handleError:
     [MikuMikuError errorWithCode:MikuMikuErrorCodeInvalidRequestMethod]];
    return;
  }
  
  // HTTP
  NSString *httpMethod = [MikuMikuConnection httpMethodWithRequest:request];
  NSString *uri = [[MikuMikuConnectionServer sharedServer] generateUriWithRequest:request];
  NSDictionary *httpHeaderFieldDictionary = [[MikuMikuConnectionServer sharedServer] httpHeaderFieldDictionary];
  NSData *jsonData = [self jsonDataWithRequest:request];
  
  NSLog(@"httpMethod = %@", httpMethod);
  NSLog(@"uri = %@", uri);
  NSLog(@"httpHeaderFieldDictionary = %@", httpHeaderFieldDictionary);
  NSLog(@"jsonData(String) = %@", [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease]);
  
  if (request.method == MikuMikuRequestMethodHttpPost && jsonData == nil) {
    [self handleError:
     [MikuMikuError errorWithCode:MikuMikuErrorCodeCannotConvertRequest]];
    return;
  }
  
  NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:uri]
                                                                  cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                              timeoutInterval:30.0] autorelease];
  for (NSString *key in httpHeaderFieldDictionary.allKeys) {
    [urlRequest setValue:httpHeaderFieldDictionary[key] forHTTPHeaderField:key];
  }
  for (NSString *key in request.httpHeaderFields.allKeys) {
    [urlRequest setValue:request.httpHeaderFields[key] forHTTPHeaderField:key];
  }
  [urlRequest setHTTPMethod:httpMethod];
  if (request.method == MikuMikuRequestMethodHttpPost) [urlRequest setHTTPBody:jsonData];
  
  NSLog(@"urlRequest.URL = %@", urlRequest.URL);
  NSLog(@"urlRequest.allHTTPHeaderFields = %@", urlRequest.allHTTPHeaderFields);
  NSLog(@"urlRequest.httpBody = %@", urlRequest.HTTPBody);
  
  self.responseData = [NSMutableData dataWithCapacity:0];
  self.didReceiveResponse = NO;
  self.didTimeOut = NO;
  self.connection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
  self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f
                                                       target:self selector:@selector(timeOutTimerDidTick)
                                                     userInfo:nil repeats:NO];
}

- (NSData*)jsonDataWithRequest:(MikuMikuRequest*)request
{
  NSDictionary *jsonDictionary = @{ @"controller" : request.controller,
                                    @"action" : request.action,
                                    @"args" : request.parameters ? request.parameters : [NSNull null]};
  
  if([NSJSONSerialization isValidJSONObject:jsonDictionary] == NO) return nil;
  
  NSError *jsonSerializationError = nil;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&jsonSerializationError];
  if(jsonSerializationError) return nil;
  
  return jsonData;
}

- (void)timeOutTimerDidTick
{
  self.didTimeOut = YES;
  [self stopTimeOutTimer];
  
  if(self.didReceiveResponse == NO){
    [self.connection cancel];
    self.connection = nil;
    [self handleError:
     [MikuMikuError errorWithCode:MikuMikuErrorCodeTimeOut]];
    return;
  }
}

- (void)stopTimeOutTimer
{
  [self.timeoutTimer invalidate];
  self.timeoutTimer = nil;
}

#pragma mark - NSURLConnectionDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  NSLog(@"MikuMikuConnection::connectionDidFinishLoading");
  if (self.didTimeOut) return;
  [self stopTimeOutTimer];
 
  NSError *serializationError = nil;
  NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:_responseData
                                                                 options:NSJSONReadingAllowFragments error:&serializationError];
  if(serializationError){
    [self handleError:
     [MikuMikuError errorWithCode:MikuMikuErrorCodeCannotSerializeJson]];
    return;
  }
  
  MikuMikuResponse *response = [MikuMikuResponse responseWithJsonDictionary:jsonDictionary request:self.request];
  
  if([_delegate respondsToSelector:@selector(mmConnection:didFinishLoading:)]){
    [_delegate mmConnection:self didFinishLoading:response];
  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  NSLog(@"MikuMikuConnection::connection:didFailWithError");
  NSLog(@"error = %@", error);
  
  if (self.didTimeOut) return;
  [self stopTimeOutTimer];
   
  self.responseData = nil;
  [self.connection cancel];
  
  [self handleError:
   [MikuMikuError errorWithCode:MikuMikuErrorCodeConnectionFailed]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  if (self.didTimeOut) return;
  [self stopTimeOutTimer];
  
  [self.responseData appendData:data];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  NSLog(@"MikuMikuConnection::connection:didReceiveResponse:");
  
  if (self.didTimeOut) return;
  [self stopTimeOutTimer];
  self.didReceiveResponse = YES;
  
  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
  
  NSLog(@" response.URL = %@", httpResponse.URL);
  NSLog(@" response.MIMEType = %@", httpResponse.MIMEType);
  NSLog(@" response.expectedContentsLength = %lli", httpResponse.expectedContentLength);
  NSLog(@" response.textEncodingName = %@", httpResponse.textEncodingName);
  NSLog(@" response.suggenstedFilename = %@", httpResponse.suggestedFilename);
  NSLog(@" response.statusCode = %d ( %@ )", httpResponse.statusCode,
        [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]);
  NSLog(@" response.allHeaderFields = %@", httpResponse.allHeaderFields);
  
  if (httpResponse.statusCode >= 400) {
    self.responseData = nil;
    [self.connection cancel];
    [self handleError:
     [MikuMikuError errorWithCode:MikuMikuErrorCodeBadStatusCode]];
    return;
  }
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
}

#pragma mark - handleError

- (void)handleError:(MikuMikuError*)error
{
  [self handleErrorImpl:error];
}

- (void)handleErrorImpl:(MikuMikuError*)error
{
 if ([_delegate respondsToSelector:@selector(mmConnection:didFailWithError:)]) {
   [_delegate mmConnection:self didFailWithError:error];
  }
}

#pragma mark - + methods

+ (id)connectionWithRequest:(MikuMikuRequest*)request delegate:(id<MikuMikuConnectionDelegate>)delegate
{
  return [[[MikuMikuConnection alloc] initWithRequest:request delegate:delegate] autorelease];
}

+ (NSString*)httpMethodWithRequest:(MikuMikuRequest*)request
{
  if (request.method == MikuMikuRequestMethodHttpGet) return @"GET";
  if (request.method == MikuMikuRequestMethodHttpPost) return @"POST";
  return nil;
}


@end
