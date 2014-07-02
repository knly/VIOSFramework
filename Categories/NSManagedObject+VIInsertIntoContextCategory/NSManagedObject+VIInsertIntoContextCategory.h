//
//  NSManagedObject+NSManagedObject_VIInsertIntoContextCategory.h
//  uni-hd
//
//  Created by Nils Fischer on 06.05.14.
//  Copyright (c) 2014 Universität Heidelberg. All rights reserved.
//

@import CoreData;


@interface NSManagedObject (VIInsertIntoContextCategory)

+ (NSString *)entityName;
- (NSString *)entityName;
+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context;

@end
