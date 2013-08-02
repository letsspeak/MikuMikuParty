//
//  TwitterController.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/08/03.
//
//

#import "TwitterController.h"
#import "TwitterAccountSelector.h"
#import "WindowLocker.h"

@interface TwitterController ()
@property (nonatomic, retain) ACAccountStore *accountStore;
@end

@implementation TwitterController

#pragma mark - singleton managements

static TwitterController *_sharedInstance = nil;

+ (TwitterController*)sharedController
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
    self.accountStore = [[ACAccountStore new] autorelease];
  }
  return self;
}

- (void)dealloc
{
  self.accountStore = nil;
  [super dealloc];
}

- (void)getTwitterAccountWithUsername:(NSString*)username
                     succeededHandler:(void(^)(ACAccount *account))succeededHandler
                        failedHandler:(void(^)(void))failedHandler
                 parentViewController:(UIViewController*)parent
{
  void(^_sh)(ACAccount* account) = [[succeededHandler copy] autorelease];
  void(^_fh)(void) = [[failedHandler copy] autorelease];
  
  ACAccountType* twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
  
  __block UIViewController *_parent = parent;
  __block WindowLocker *locker = [WindowLocker loadingLocker];
  [self.accountStore requestAccessToAccountsWithType:twitterType
                               withCompletionHandler:^(BOOL granted, NSError* error)
   {
     [locker close];
     
     if (granted == NO) {
       if (_fh) _fh();
       return;
     }
     
     NSArray* accounts = [self.accountStore accountsWithAccountType:twitterType];
     
     if (accounts.count == 0) {
       if (_fh) _fh();
       return;
     }
     
     if (username == nil) {
       
       if (_parent == nil) {
         if (_fh) _fh();
         return;
       }
       
       TwitterAccountSelector *selector = [TwitterAccountSelector selectorWithAccounts:accounts
                                                                       selectedHandler:^(ACAccount *account)
                                           {
                                             if (account && _sh) _sh(account);
                                             else if (_fh) _fh();
                                           } cancelHandler:^{
                                             if (_fh) _fh();
                                           }];
       [_parent presentModalViewController:selector animated:YES];
       return;
     }
     
     ACAccount *gotAccount = nil;
     for(ACAccount *account in accounts){
       if([account.username isEqualToString:username]){
         gotAccount = account;
         break;
       }
     }
     
     if (gotAccount) {
       if (_sh) _sh(gotAccount);
     }else {
       if (_fh) _fh();
     }
   }];
}

#pragma mark - + methods

+ (void)getTwitterAccountWithUsername:(NSString*)username
                     succeededHandler:(void(^)(ACAccount *account))succeededHandler
                        failedHandler:(void(^)(void))failedHandler
                 parentViewController:(UIViewController*)parent
{
  [[self sharedController] getTwitterAccountWithUsername:username
                                        succeededHandler:succeededHandler
                                           failedHandler:failedHandler
                                    parentViewController:parent];
}


@end
