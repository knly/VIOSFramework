//
//  VIFetchRequestDataSource.m
//  uni-hd
//
//  Created by Nils Fischer on 06.05.14.
//  Copyright (c) 2014 Universität Heidelberg. All rights reserved.
//

#import "VIFetchedResultsControllerDataSource.h"
#import "VILogger.h"

@interface VIFetchedResultsControllerDataSource ()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UITableView *tableView;
@property (copy, nonatomic) NSString *cellIdentifier;
@property (copy, nonatomic) VITableViewCellConfigureBlock configureCellBlock;

@end


@implementation VIFetchedResultsControllerDataSource


#pragma mark - Object Lifecycle

- (id)init {
    return nil;
}

- (id)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController tableView:(UITableView *)tableView cellIdentifier:(NSString *)cellIdentifier configureCellBlock:(VITableViewCellConfigureBlock)configureCellBlock
{
    if ((self = [super init])) {
        self.fetchedResultsController = fetchedResultsController;
        self.tableView = tableView;
        if (tableView) {
            tableView.dataSource = self;
            [self.logger log:@"Redirected Table View Datasource" forLevel:VILogLevelVerbose];
        }
        self.cellIdentifier = cellIdentifier;
        self.configureCellBlock = configureCellBlock;
    }
    return self;
}

- (void)setFetchedResultsController:(NSFetchedResultsController*)fetchedResultsController
{
    _fetchedResultsController = fetchedResultsController;
    fetchedResultsController.delegate = self;
    NSError *error = nil;
    [self.logger log:@"Perform fetch ..." forLevel:VILogLevelVerbose];
    if (![fetchedResultsController performFetch:&error]) [self.logger log:@"Perform Fetch" error:error];
    else [self.logger log:[NSString stringWithFormat:@"Fetched %lu Objects", [fetchedResultsController fetchedObjects].count] forLevel:VILogLevelVerbose];
}


#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    id <NSFetchedResultsSectionInfo> section = self.fetchedResultsController.sections[sectionIndex];
    return section.numberOfObjects;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    id cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    id object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.configureCellBlock(cell, object);
    return cell;
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return self.delegate && [self.delegate respondsToSelector:@selector(deleteObject:)];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.logger log:@"Attempting to delete" object:object forLevel:VILogLevelVerbose];
        [self.delegate deleteObject:object];
    }
}


#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
    [self.logger log:@"Begin updates" forLevel:VILogLevelVerbose];
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
    [self.logger log:@"End updates" forLevel:VILogLevelVerbose];
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath*)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath*)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.logger log:@"Inserted at index path" object:indexPath forLevel:VILogLevelVerbose];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeMove:
            [self.logger log:@"Moved at index path" object:indexPath forLevel:VILogLevelVerbose];
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
        case NSFetchedResultsChangeDelete:
            [self.logger log:@"Deleted at index path" object:indexPath forLevel:VILogLevelVerbose];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}


- (id)selectedItem
{
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    return indexPath ? [self.fetchedResultsController objectAtIndexPath:indexPath] : nil;
}


# pragma mark - Pausing

- (void)setPaused:(BOOL)paused
{
    _paused = paused;
    if (paused) {
        self.fetchedResultsController.delegate = nil;
    } else {
        self.fetchedResultsController.delegate = self;
        [self.fetchedResultsController performFetch:NULL];
        [self.tableView reloadData];
    }
}

@end
