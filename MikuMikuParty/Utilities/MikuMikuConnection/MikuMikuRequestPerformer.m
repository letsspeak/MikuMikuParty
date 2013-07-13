//
//  MikuMikuRequestPerformer.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/13.
//
//

#import "MikuMikuRequestPerformer.h"

@interface MikuMikuRequestPerformer ()
@property (nonatomic, retain) NSMutableArray *connectionArray;
@end

@implementation MikuMikuRequestPerformer

#pragma mark - singleton managements

static MikuMikuRequestPerformer *_sharedInstance = nil;
static BOOL _willDelete = NO;

+ (MikuMikuRequestPerformer*)sharedPerformer
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
      _willDelete = YES;
      [_sharedInstance release];
      _sharedInstance = nil;
      _willDelete = NO;
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
  @synchronized(self) {
    if (_willDelete) {
      [super release];
    }
  }
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
    self.connectionArray = [NSMutableArray array];
  }
  return self;
}

- (void)dealloc
{
  self.connectionArray = nil;
  [super dealloc];
}

- (void)performRequest:(MikuMikuRequest*)request
{
  // TODO : check mocks
  
  MikuMikuConnection *connection = [MikuMikuConnection connectionWithRequest:request delegate:self];
  [self.connectionArray addObject:connection];
}

- (void)mmConnection:(MikuMikuConnection *)connection didFinishLoading:(MikuMikuResponse *)response
{
  void(^sh_)(MikuMikuResponse *response)  = connection.request.succeededHandler;
  if (sh_) sh_(response);
  [self.connectionArray removeObject:connection];
}

- (void)mmConnection:(MikuMikuConnection *)connection didFailWithError:(MikuMikuError *)error
{
  void(^fh_)(MikuMikuError *error)  = connection.request.failedHandler;
  if (fh_) fh_(error);
  [self.connectionArray removeObject:connection];
}

@end
