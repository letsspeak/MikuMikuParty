//
//  TwitterAccountSelector.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/08/03.
//
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@interface TwitterAccountSelector : UIViewController
<UITableViewDataSource, UITableViewDelegate>

+ (id)selectorWithAccounts:(NSArray*)accounts
           selectedHandler:(void(^)(ACAccount *account))selectedHandler
             cancelHandler:(void(^)(void))cancelHandler;

@end
