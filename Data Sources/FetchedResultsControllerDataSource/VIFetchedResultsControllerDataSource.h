//
//  Created by Nils Fischer
//  with reference: http://www.objc.io/issue-4/full-core-data-application.html
//

@import Foundation;
@import UIKit;
@import CoreData;

typedef void (^VITableViewCellConfigureBlock)(UITableViewCell *cell, id item);


@protocol VIFetchedResultsControllerDataSourceDelegate

@optional
- (void)deleteObject:(id)object;

@end


@interface VIFetchedResultsControllerDataSource : NSObject <UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) id <VIFetchedResultsControllerDataSourceDelegate, NSObject> delegate;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UITableView *tableView;
@property (copy, nonatomic) NSString *cellIdentifier;
@property (copy, nonatomic) VITableViewCellConfigureBlock configureCellBlock;

@property (nonatomic) BOOL showIndexTitles;
@property (nonatomic) BOOL paused;

- (id)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController tableView:(UITableView *)tableView cellIdentifier:(NSString *)cellIdentifier configureCellBlock:(VITableViewCellConfigureBlock)configureCellBlock;
- (NSFetchedResultsController *)fetchedResultsController;

- (id)selectedItem;
- (void)reloadData;

@end
