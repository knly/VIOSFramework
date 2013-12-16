//
//  VIDatabaseController.h
//  VIFramework
//
//  Created by Nils Fischer on 01.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@import Foundation;
@import CoreData;
#import "VIManager.h"

@protocol VIDatabaseManagerDelegate;

@interface VIDatabaseManager : VIManager
    
@property (weak, nonatomic) id <VIDatabaseManagerDelegate> delegate;
    
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext:(NSManagedObjectContext *)managedObjectContext;

@end

@protocol VIDatabaseManagerDelegate

// provide the file name of the managed object model file
- (NSString *)managedObjectModelResourceNameForDatabaseManager:(VIDatabaseManager *)databaseManager;

@optional

// provide an url for the storage file, e.g. [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"filename.sqlite"]
- (NSURL *)databaseFileURLForDatabaseManager:(VIDatabaseManager *)databaseManager;

@end