//
//  MikuMikuDownloader.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/17.
//
//

#import "MikuMikuDownloader.h"


@implementation MikuMikuDownloader

- (id)init
{
  self = [super init];
  if (self) {
    self.url = nil;
    self.filePath = nil;
    self.temporarySucceededHandler = nil;
    self.temporaryFailedHandler = nil;
    self.temporaryDirectory = NSTemporaryDirectory();
  }
  return self;
}

- (void)dealloc
{
  self.url = nil;
  self.filePath = nil;
  self.temporarySucceededHandler = nil;
  self.temporaryFailedHandler = nil;
  [super dealloc];
}

+ (void)temporaryDownloadWithUrl:(NSString*)url
                succeededHandler:(void(^)(NSString *temporaryPath))succeededHandler
                   failedHandler:(void(^)(MikuMikuError *error))failedHandler
{
  MikuMikuDownloader *downloader = [[MikuMikuDownloader alloc] init];
  downloader.url = url;
  downloader.temporarySucceededHandler = succeededHandler;
  downloader.temporaryFailedHandler = failedHandler;
  [downloader temporaryDownload];
}
- (void)temporaryDownload
{
  self.isTemporaryDownload = YES;
  self.filePath = [self pathForTemporaryFileWithPrefix:@"mmd"];
  
  NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]
                                                                  cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                              timeoutInterval:30.0] autorelease];
 [request setHTTPMethod:@"GET"];
  self.responseData = [NSMutableData dataWithCapacity:0];
  self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix
{
  NSString *  result;
  CFUUIDRef   uuid;
  CFStringRef uuidStr;
  
  uuid = CFUUIDCreate(NULL);
  assert(uuid != NULL);
  
  uuidStr = CFUUIDCreateString(NULL, uuid);
  assert(uuidStr != NULL);
  
  result = [self.temporaryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", prefix, uuidStr]];
  assert(result != nil);
  
  CFRelease(uuidStr);
  CFRelease(uuid);
  
  return result;
}

#pragma mark - NSURLConnectionDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  NSLog(@"MikuMikuDownloader::connectionDidFinishLoading");
  
//  NSLog(@"self.responseData = %@", self.responseData);
  [self.responseData writeToFile:self.filePath atomically:YES];
  
  if (self.isTemporaryDownload) {
    if (self.temporarySucceededHandler) {
      self.temporarySucceededHandler(self.filePath);
    }
  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  NSLog(@"MikuMikuDownloader::connection:didFailWithError");
  NSLog(@"error = %@", error);
  
  self.responseData = nil;
  [self.connection cancel];
  
  [self handleError:
   [MikuMikuError errorWithCode:MikuMikuErrorCodeConnectionFailed]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  [self.responseData appendData:data];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  NSLog(@"MikuMikuDownloader::connection:didReceiveResponse:");
  
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
  // TODO : 
}

#pragma mark - handleError

- (void)handleError:(MikuMikuError*)error
{
  if (self.isTemporaryDownload) {
    if (self.temporaryFailedHandler) {
      self.temporaryFailedHandler(error);
    }
  }
}

@end
