//
//  MMDHubItemCollection.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/15.
//
//

#import "MMDHubItemCollection.h"

@implementation MMDHubItemCollection

- (id)init
{
  self = [super init];
  if (self) {
    self.items = [NSMutableArray array];
  }
  return self;
}

- (id)initWithItemDics:(NSArray*)itemDics
{
  self = [self init];
  if (self) {
    for (NSDictionary *itemDic in itemDics) {
      [self.items addObject:[MMDHubItem itemWithItemDic:itemDic]];
    }
  }
  return self;
}

- (NSInteger)itemCountWithCategory:(MMDHubItemCategory)category
{
  int count = 0;
  for (MMDHubItem *item in self.items) {
    if (item.category == category) count++;
  }
  return count;
}

- (MMDHubItem*)itemWithCategory:(MMDHubItemCategory)category order:(NSInteger)order;
{
  int count = 0;
  for (MMDHubItem *item in self.items) {
    if (item.category == category) {
      if (count == order) return item;
      count++;
    }
  }
  return nil;
}

+ (id)collectionWithItemDics:(NSArray*)itemDics
{
  return [[[self alloc] initWithItemDics:itemDics] autorelease];
}

@end
