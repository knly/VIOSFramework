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

- (void)performFetch;

@end


@implementation VIFetchedResultsControllerDataSource


#pragma mark - Object Lifecycle

- (id)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController tableView:(UITableView *)tableView cellIdentifier:(NSString *)cellIdentifier configureCellBlock:(VITableViewCellConfigureBlock)configureCellBlock
{
    if ((self = [super init])) {
        self.fetchedResultsController = fetchedResultsController;
        self.tableView = tableView;
        if (tableView) {
            tableView.dataSource = self;
            [self.logger log:@"Redirected table view datasource" forLevel:VILogLevelInfo];
        }
        self.cellIdentifier = cellIdentifier;
        self.configureCellBlock = configureCellBlock;
    }
    return self;
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    _fetchedResultsController = fetchedResultsController;
    fetchedResultsController.delegate = self;
    [self performFetch];
}

- (void)performFetch
{
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) [self.logger log:@"Perform Fetch" error:error];
    else [self.logger log:[NSString stringWithFormat:@"Fetched %d objects in %d sections", (int)self.fetchedResultsController.fetchedObjects.count, (int)self.fetchedResultsController.sections.count] forLevel:VILogLevelVerbose];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.name;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (!self.showIndexTitles) return nil;
    return self.fetchedResultsController.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
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

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.logger log:@"Inserted section at index" object:@(sectionIndex) forLevel:VILogLevelVerbose];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.logger log:@"Deleted section at index" object:@(sectionIndex) forLevel:VILogLevelVerbose];
            break;
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath*)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath*)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[ newIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.logger log:@"Inserted row at index path" object:newIndexPath forLevel:VILogLevelVerbose];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
            [self.logger log:@"Moved row at index path" object:indexPath forLevel:VILogLevelVerbose];
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.logger log:@"Deleted row at index path" object:indexPath forLevel:VILogLevelVerbose];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.logger log:@"Updated row at index path" object:indexPath forLevel:VILogLevelVerbose];
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


#pragma mark - Reloading

- (void)reloadData
{
    [self performFetch];
    [self.tableView reloadData];
}

@end
