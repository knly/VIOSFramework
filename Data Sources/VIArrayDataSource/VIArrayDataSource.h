//
//  VIArrayDataSource.h
//  living
//
//  Created by Nils Fischer on 28.05.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

@import Foundation;
#import "VIArraySectionInfo.h"

@interface VIArrayDataSource : NSObject

@property (strong, nonatomic) NSArray *array;
@property (strong, nonatomic) NSArray *sortDescriptors;
@property (strong, nonatomic) NSString *sectionNameKeyPath;

- (id)initWithArray:(NSArray *)array sortDescriptors:(NSArray *)sortDescriptors sectionNameKeyPath:(NSString *)keyPath;

- (NSArray *)sortDescriptors;
- (NSString *)sectionNameKeyPath;

- (NSArray *)objects;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

- (NSArray *)sections;
- (NSArray *)sectionIndexTitles;
- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;

@end
