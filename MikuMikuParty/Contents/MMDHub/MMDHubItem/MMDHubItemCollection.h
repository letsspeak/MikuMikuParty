//
//  MMDHubItemCollection.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/15.
//
//

#import <Foundation/Foundation.h>
#import "MMDHubItem.h"

@interface MMDHubItemCollection : NSObject

@property (nonatomic, retain) NSMutableArray *items;

- (NSInteger)itemCountWithCategory:(MMDHubItemCategory)category;
- (MMDHubItem*)itemWithCategory:(MMDHubItemCategory)category order:(NSInteger)order;

+ (id)collectionWithItemDics:(NSArray*)items;

@end
