//
//  MMDHubItem.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/15.
//
//

#import "MMDHubItem.h"

@implementation MMDHubItem

- (id)initWithItemDic:(NSDictionary*)itemDic
{
  self = [super init];
  if (self) {
    self.itemId = [itemDic[@"id"] integerValue];
    self.title = itemDic[@"title"];
    self.category = [itemDic[@"category"] integerValue];
    self.parentId = [itemDic[@"parent_id"] integerValue];
    self.thumbnail = itemDic[@"thumbnail"];
    self.filename = itemDic[@"filename"];
    self.size = [itemDic[@"size"] integerValue];
    self.digest = itemDic[@"digest"];
    self.isPublic = [itemDic[@"is_public"] boolValue];
  }
  return self;
}

+ (id)itemWithItemDic:(NSDictionary*)itemDic
{
  return [[[self alloc] initWithItemDic:itemDic] autorelease];
}

+ (NSString*)nameWithCategory:(MMDHubItemCategory)category
{
  switch (category) {
    case MMDHubItemCategoryImage:         return @"画像";
    case MMDHubItemCategoryMovie:         return @"動画";
    case MMDHubItemCategoryMusic:         return @"音楽";
    case MMDHubItemCategoryDocument:      return @"文書";
    case MMDHubItemCategoryMMDModel:      return @"MMDモデル";
    case MMDHubItemCategoryMMDAccessory:  return @"MMDアクセサリ";
    case MMDHubItemCategoryMMDMotion:     return @"MMDモーション";
    case MMDHubItemCategoryPMDPlugin:     return @"PMDプラグイン";
    case MMDHubItemCategoryMMEPlugin:     return @"MMEプラグイン";
    default:
      return @"その他";
  }
}

+ (NSString*)stringWithSize:(NSInteger)size;
{
  if (size < 1024) {
    // < 1KB
    return [NSString stringWithFormat:@"%dB", size];
  } else if (size < 1048576) {
    // < 1MB
    return [NSString stringWithFormat:@"%dKB", size / 1024];
  } else if (size < 10485760) {
    // < 10MB
    return [NSString stringWithFormat:@"%.1fMB", (float)size / (float)(1024*1024)];
  } else {
    // >= 10MB
    return [NSString stringWithFormat:@"%dMB", size / (1024 * 1024)];
  }
}

@end
