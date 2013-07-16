//
//  DownloadController.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/17.
//
//

#import <Foundation/Foundation.h>
#import "MMDHubItemCollection.h"

@interface DownloadController : NSObject

- (void)downloadItem:(MMDHubItem*)item;

+ (DownloadController*)sharedController;

@end
