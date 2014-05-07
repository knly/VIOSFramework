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
        tableView.dataSource = self;
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
    [fetchedResultsController performFetch:&error];
    [self.logger log:@"Fetch failed" error:error];
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
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.delegate deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
}


#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath*)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath*)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}


- (id)selectedItem
{
    NSIndexPath* path = self.tableView.indexPathForSelectedRow;
    return path ? [self.fetchedResultsController objectAtIndexPath:path] : nil;
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
