//
//  MMDHubItemTableView.m
//  MikuMikuParty
//
//  Created by letsspeak on 13/07/14.
//
//

#import "MMDHubItemTableView.h"
#import "ItemDetailViewController.h"

static NSString *MMDHubItemTableViewCellIdentifier = @"MMDHubItemTableViewCellIdentifier";

@implementation MMDHubItemTableView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self initialization];
  }
  return self;
}

- (void)awakeFromNib
{
  [self initialization];
}

- (void)initialization
{
  self.dataSource = self;
  self.delegate = self;
  self.itemCollection = [[MMDHubItemCollection new] autorelease];
}

- (void)setItemCollection:(MMDHubItemCollection *)itemCollection
{
  if (_itemCollection) [_itemCollection release];
  _itemCollection = [itemCollection retain];
  [self reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return MMDHubItemCategoryCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  int category = section + 1;
  return [MMDHubItem nameWithCategory:category];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  int category = section + 1;
  return [self.itemCollection itemCountWithCategory:category];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MMDHubItemTableViewCellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc]
             initWithStyle:UITableViewCellStyleSubtitle
             reuseIdentifier:MMDHubItemTableViewCellIdentifier] autorelease];
  }
  
  MMDHubItem *item = [self itemWithIndexPath:indexPath];
  cell.textLabel.text = item.title;
  cell.detailTextLabel.text = item.filename;
  cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y,
                          cell.frame.size.width, cell.frame.size.height + 20);
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//  NSDictionary *item = [self itemWithIndexPath:indexPath];
//  int category = [item[@"category"] integerValue];
//  if (category == ITEM_CATEGORY_MMD_MODEL) return 100;
//  if (category == ITEM_CATEGORY_MMD_MOTION) return 100;
  return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  MMDHubItem *item = [self itemWithIndexPath:indexPath];
  ItemDetailViewController *controller = [ItemDetailViewController controllerWithItem:item];
  [self.parentViewController.navigationController pushViewController:controller animated:YES];
}

- (MMDHubItem*)itemWithIndexPath:(NSIndexPath*)indexPath
{
  int category = indexPath.section + 1;
  int order = indexPath.row;
  return [self.itemCollection itemWithCategory:category order:order];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
