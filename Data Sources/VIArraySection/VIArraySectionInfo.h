//
//  VISectionInfo.h
//  living
//
//  Created by Nils Fischer on 28.05.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

@import Foundation;

@protocol VIArraySectionInfo

- (NSInteger)numberOfObjects;
- (NSArray *)objects;
- (NSString *)name;
- (NSString *)indexTitle;

@end
