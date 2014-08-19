//
//  VIArrayDataSource.m
//  living
//
//  Created by Nils Fischer on 28.05.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

#import "VIArrayDataSource.h"
#import "VIArraySection.h"
#import "VILogger.h"

@interface VIArrayDataSource ()

@property (strong, nonatomic) NSArray *objects;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) NSArray *sectionIndexTitles;

@end


@implementation VIArrayDataSource

- (id)initWithArray:(NSArray *)array sortDescriptors:(NSArray *)sortDescriptors sectionNameKeyPath:(NSString *)keyPath cellBlock:(VITableViewCellDequeueAndConfigureBlock)cellBlock
{
    if ((self = [super init])) {
        
        self.array = array;
        self.sortDescriptors = sortDescriptors;
        self.sectionNameKeyPath = keyPath;
        self.cellBlock = cellBlock;
        
    }
    return self;
}

- (void)setArray:(NSArray *)array
{
    _array = array;
    [self reloadData];
}

- (void)setSortDescriptors:(NSArray *)sortDescriptors
{
    _sortDescriptors = sortDescriptors;
    [self reloadData];
}

- (void)setSectionNameKeyPath:(NSString *)sectionNameKeyPath
{
    _sectionNameKeyPath = sectionNameKeyPath;
    [self reloadData];
}

- (void)reloadData
{
    self.objects = nil;
    self.sections = nil;
    self.sectionIndexTitles = nil;
}

- (NSArray *)objects
{
    if (!_objects) {
        if (self.sortDescriptors) self.objects = [self.array sortedArrayUsingDescriptors:self.sortDescriptors];
        else self.objects = self.array;
        self.sections = nil;
    }
    return _objects;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return [(id<VIArraySectionInfo>)self.sections[indexPath.section] objects][indexPath.row];
}

- (NSArray *)sections
{
    if (!_sections) {
        NSArray *objects = self.objects;
        NSMutableArray *sections = [[NSMutableArray alloc] init];
        VIArraySection *section = nil;
        for (id object in objects) {
            NSString *sectionName = (self.sectionNameKeyPath) ? [object valueForKey:self.sectionNameKeyPath] : nil;
            if (!section || ( self.sectionNameKeyPath && !( [section.name isEqualToString:sectionName] || (!section.name && sectionName) ) )) {
                section = [[VIArraySection alloc] init];
                section.name = sectionName;
                section.indexTitle = [[sectionName substringToIndex:1] capitalizedString];
                [sections addObject:section];
            }
            [section addObject:object];
        }
        self.sections = sections;
        self.sectionIndexTitles = nil;
    }
    return _sections;
}

- (NSArray *)sectionIndexTitles
{
    if (!_sectionIndexTitles) {
        NSMutableArray *titles = [[NSMutableArray alloc] init];
        for (id <VIArraySectionInfo> section in self.sections) {
            if (section.indexTitle) [titles addObject:section.indexTitle];
        }
        self.sectionIndexTitles = titles;
    }
    return _sectionIndexTitles;
}

- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}


#pragma mark - UITableViewDataSource Implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(id<VIArraySectionInfo>)self.sections[section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.cellBlock) {
        [self.logger log:@"No VITableViewCellDequeueAndConfigureBlock provided. Set the cellBlock property to dequeue and configure a table view cell in a block." forLevel:VILogLevelError];
        abort();
    }
    return self.cellBlock(tableView, indexPath, [self objectAtIndexPath:indexPath]);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [(id<VIArraySectionInfo>)self.sections[section] name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self sectionForSectionIndexTitle:title atIndex:index];
}

@end
