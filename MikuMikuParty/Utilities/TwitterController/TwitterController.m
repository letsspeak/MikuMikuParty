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

@end

@implementation TwitterController

+ (void)getTwitterAccountWithUsername:(NSString*)username
                     succeededHandler:(void(^)(ACAccount *account))succeededHandler
                        failedHandler:(void(^)(void))failedHandler
                 parentViewController:(UIViewController*)parent
{
  void(^_sh)(ACAccount* account) = [[succeededHandler copy] autorelease];
  void(^_fh)(void) = [[failedHandler copy] autorelease];
  
  ACAccountStore *accountStore = [[ACAccountStore new] autorelease];
  ACAccountType* twitterType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
  
  __block UIViewController *_parent = parent;
  __block WindowLocker *locker = [WindowLocker loadingLocker];
  [accountStore requestAccessToAccountsWithType:twitterType
                          withCompletionHandler:^(BOOL granted, NSError* error)
   {
     [locker close];
     
     if (granted == NO) {
       if (_fh) _fh();
       return;
     }
     
     NSArray* accounts = [accountStore accountsWithAccountType:twitterType];
     
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


@end
