//
//  VISectionInfo.h
//  living
//
//  Created by Nils Fischer on 28.05.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

@import Foundation;

@protocol VIArraySectionInfo

@property (readonly) NSInteger numberOfObjects;
@property (readonly) NSArray *objects;
@property (readonly) NSString *name;
@property (readonly) NSString *indexTitle;

@end
