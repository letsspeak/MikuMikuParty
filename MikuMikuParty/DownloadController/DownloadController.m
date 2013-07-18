//
//  DownloadController.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/17.
//
//

#import "DownloadController.h"
#import "MikuMikuConnection.h"
#import "MikuMikuDownloader.h"
#import "ZipArchive.h"

@implementation DownloadController



#pragma mark - singleton managements

static DownloadController *_sharedInstance = nil;

+ (DownloadController*)sharedController
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
    // TODO : downloaded item status managements
  }
  return self;
}

- (void)downloadItem:(MMDHubItem*)item
{
  NSLog(@"DownloadController::downloadItem:");
  NSLog(@"item = %@, (id = %d, digest = %@", item, item.itemId, item.digest);
  
  MikuMikuRequest *request = [MikuMikuRequest requestWithController:@"items" action:@"download_url"];
  request.urlPrameterString = [NSString stringWithFormat:@"%d", item.itemId];
  request.method = MikuMikuRequestMethodHttpGet;
  [request performRequestWithSucceededHandler:^(MikuMikuResponse *response) {
    
    NSLog(@"url = %@", response[@"download_url"]);
    [self downloadItem:item from:response[@"download_url"]];
    
  } failedHandler:^(MikuMikuError *error) {
    
    NSLog(@"items/download_url/:id failed.");
    
  }];
}

- (void)downloadItem:(MMDHubItem *)item from:(NSString*)url
{
  NSLog(@"DownloadController::downloadItem:from:");
  NSLog(@"item = %@, (id = %d, digest = %@", item, item.itemId, item.digest);
  NSLog(@"url = %@", url);
  
  [MikuMikuDownloader temporaryDownloadWithUrl:url
                              succeededHandler:
   ^(NSString *temporaryPath){
     
     NSLog(@"MikuMikuDownloader download succeeded.");
     NSLog(@"temporaryPath = %@", temporaryPath);
     
     [self unzipItem:item withZipPath:temporaryPath];

   
   } failedHandler:^(MikuMikuError *error){
     
     NSLog(@"MikuMikuDownloader download failed.");
     NSLog(@"error = %@" , error);
  
   }];
}

- (void)unzipItem:(MMDHubItem*)item withZipPath:(NSString*)zipPath
{
  NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
  NSLog(@"documentPath = %@", documentPath);
  NSString *unzipPath = [documentPath stringByAppendingFormat:@"/Downloads/%@", item.digest];
  
  NSLog(@"unzip...");
  ZipArchive* za = [[[ZipArchive alloc] init] autorelease];
  if([za UnzipOpenFile:zipPath]) {
    
    BOOL ret = [za UnzipFileTo:unzipPath overWrite:YES];
    if(NO == ret) {
      // エラー処理
      NSLog(@"unzip error!");
    }
    [za UnzipCloseFile];
  }
  NSLog(@"unzip completed.");
  
  [[NSFileManager defaultManager] removeItemAtPath:zipPath error:nil];
}

- (NSString *)pathForTemporaryPath
{
  NSString *  result;
  CFUUIDRef   uuid;
  CFStringRef uuidStr;
  
  uuid = CFUUIDCreate(NULL);
  assert(uuid != NULL);
  
  uuidStr = CFUUIDCreateString(NULL, uuid);
  assert(uuidStr != NULL);
  
  result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", uuidStr]];
  assert(result != nil);
  
  CFRelease(uuidStr);
  CFRelease(uuid);
  
  return result;
}

@end
