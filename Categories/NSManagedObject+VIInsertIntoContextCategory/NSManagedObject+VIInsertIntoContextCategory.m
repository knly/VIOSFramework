//
//  NSManagedObject+NSManagedObject_VIInsertIntoContextCategory.m
//  uni-hd
//
//  Created by Nils Fischer on 06.05.14.
//  Copyright (c) 2014 Universität Heidelberg. All rights reserved.
//

#import "NSManagedObject+VIInsertIntoContextCategory.h"

@implementation NSManagedObject (VIInsertIntoContextCategory)

+ (NSString *)entityName
{
    return [NSStringFromClass([self class]) componentsSeparatedByString:@"."].lastObject;
}

- (NSString *)entityName
{
    return [[self class] entityName];
}

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

@end
