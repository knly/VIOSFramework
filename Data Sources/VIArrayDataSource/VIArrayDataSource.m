//
//  VIArrayDataSource.m
//  living
//
//  Created by Nils Fischer on 28.05.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

#import "VIArrayDataSource.h"
#import "VIArraySection.h"


@interface VIArrayDataSource ()

@property (strong, nonatomic) NSArray *objects;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) NSArray *sectionIndexTitles;

@end


@implementation VIArrayDataSource

- (id)initWithArray:(NSArray *)array sortDescriptors:(NSArray *)sortDescriptors sectionNameKeyPath:(NSString *)keyPath
{
    if ((self = [super init])) {
        
        self.array = array;
        self.sortDescriptors = sortDescriptors;
        self.sectionNameKeyPath = keyPath;
        
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
        self.objects = [self.array sortedArrayUsingDescriptors:self.sortDescriptors];
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
            if (!section || (!section.name && sectionName) || ![section.name isEqualToString:sectionName]) {
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

@end
