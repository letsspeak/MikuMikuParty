//
//  MMDHubItem.h
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/15.
//
//

#import <Foundation/Foundation.h>


typedef enum {
  MMDHubItemCategoryUndefined     = 0,
  MMDHubItemCategoryImage         = 1,
  MMDHubItemCategoryMovie         = 2,
  MMDHubItemCategoryMusic         = 3,
  MMDHubItemCategoryDocument      = 4,
  MMDHubItemCategoryMMDModel      = 5,
  MMDHubItemCategoryMMDAccessory  = 6,
  MMDHubItemCategoryMMDMotion     = 7,
  MMDHubItemCategoryPMDPlugin     = 8,
  MMDHubItemCategoryMMEPlugin     = 9,
  
  MMDHubItemCategoryCount         = 9,
}MMDHubItemCategory;

@interface MMDHubItem : NSObject

@property (nonatomic, assign) NSInteger itemId;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) MMDHubItemCategory category;
@property (nonatomic, assign) NSInteger parentId;
@property (nonatomic, retain) NSString *thumbnail;

@property (nonatomic, retain) NSString *filename;
@property (nonatomic ,assign) NSInteger size;

@property (nonatomic, retain) NSString *digest;
@property (nonatomic, assign) BOOL isPublic;

+ (id)itemWithItemDic:(NSDictionary*)itemDic;
+ (NSString*)nameWithCategory:(MMDHubItemCategory)category;
+ (NSString*)stringWithSize:(NSInteger)size;

@end
