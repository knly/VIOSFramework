//
//  VIDatabaseController.m
//  VIFramework
//
//  Created by Nils Fischer on 01.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VIDatabaseManager.h"

@interface VIDatabaseManager ()
    
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
- (NSURL *)databaseFileURL;
- (NSURL *)managedObjectModelFileURL;

@end

@implementation VIDatabaseManager

- (void)saveContext:(NSManagedObjectContext *)managedObjectContext {
    NSError *error = nil;
    if (!managedObjectContext) managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            [self.logger log:@"save context failed" error:error];
            abort();
        } 
    }
    [self.logger log:@"saved context" object:managedObjectContext forLevel:VILogLevelDebug];
}

#pragma mark - Database File and Model File URLs

- (NSURL *)databaseFileURL {
    NSURL *databaseFileURL = nil;
    if ([(NSObject *)self.delegate respondsToSelector:@selector(databaseFileURLForDatabaseManager:)]) {
        databaseFileURL = [self.delegate databaseFileURLForDatabaseManager:self];
    }
    if (!databaseFileURL) {
        databaseFileURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"db.sqlite"];
    }
    return databaseFileURL;
}

- (NSURL *)managedObjectModelFileURL {
    NSString *str = [self.delegate managedObjectModelResourceNameForDatabaseManager:self];
    NSURL *url = [[NSBundle mainBundle] URLForResource:str withExtension:@"momd"];
    return url;
}

#pragma mark - Core Data Setup
    
- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
        if (coordinator) {
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            _managedObjectContext.persistentStoreCoordinator = coordinator;
        }
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (!_managedObjectModel) {
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[self managedObjectModelFileURL]];
    }
    return _managedObjectModel;
}
    
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self databaseFileURL] options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.
             
             
             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
             
             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
             
             * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
             @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
             
             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return _persistentStoreCoordinator;
}

/*
- (void)prepareReloadFromFile {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:VIDatabaseControllerWillReloadFromFileNotification object:nil]];
    [self saveContext];
    
}
- (void)reloadFromFile {
    persistentStoreCoordinator = nil;
    managedObjectModel = nil;
    managedObjectContext = nil;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:VIDatabaseControllerDidReloadFromFileNotification object:nil]];
}

#pragma mark - Export & Import

- (NSData *)exportData {
    return [NSData dataWithContentsOfURL:[self urlForStorageFile]];
}

- (NSString *)exportFilename {
    return [delegate exportFilename];
}

- (BOOL)importFromURL:(NSURL *)importURL {
    
    [self prepareReloadFromFile];

    NSFileManager *filemanager = [NSFileManager defaultManager];

    if (!importURL||![importURL isFileURL]||![filemanager fileExistsAtPath:[importURL path]]) return NO;
        
    NSURL *urlForStorageFile = [self urlForStorageFile];
    
    NSLog(@"storageFileUrl: %@",[urlForStorageFile path]);
    BOOL isExistingFile = [filemanager fileExistsAtPath:[urlForStorageFile path]];
    NSLog(@"storageFileExists: %i",isExistingFile);
    
    if (isExistingFile) {
        // remove existing file
        NSError *removeError = nil;
        if (![filemanager removeItemAtURL:urlForStorageFile error:&removeError]) {
            // handle error
            return NO;
        }
    }
    
    // cope new file
    NSError *copyError = nil;
    if (![filemanager copyItemAtURL:importURL toURL:urlForStorageFile error:&copyError]) {
        // handle error
        return NO;
    }
    
    NSLog(@"file imported!");
    [self reloadFromFile];
    //NSLog(@"%i",[self retainCount]);
    
    if (!dbexits) {
        
        // The writable database does not exist, so copy the default to the appropriate location.
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"DataBaseName.sqlite"];
        
        NSError *error;
        BOOL success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        if (!success) {
            
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
            
        }
        
    }
    
    return YES;
}*/

@end
