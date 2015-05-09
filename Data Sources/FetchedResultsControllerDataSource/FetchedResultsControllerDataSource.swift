//
//  FetchedResultsControllerDataSource.swift
//  VIDataSourceKit
//
//  Created by Nils Fischer on 20.10.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

import CoreData
import Evergreen

// TODO: make generic when the segmentation fault is fixed:
// public class FetchedResultsControllerDataSource<T>: NSObject {
public class FetchedResultsControllerDataSource: NSObject {
    
    public let fetchedResultsController: NSFetchedResultsController
    public weak var tableView: UITableView?
    
    public var showSectionIndexTitles = true
    
    /// Block providing a configured table view cell for a given element
    public var cellForElement: ((element: NSManagedObject, indexPath: NSIndexPath, tableView: UITableView) -> UITableViewCell)?
    
    
    // MARK: Initializers
    
    public init(fetchedResultsController: NSFetchedResultsController, tableView: UITableView? = nil, cellForElement: ((element: NSManagedObject, indexPath: NSIndexPath, tableView: UITableView) -> UITableViewCell)? = nil) {
        self.fetchedResultsController = fetchedResultsController
        self.tableView = tableView
        self.cellForElement = cellForElement
        super.init()
        fetchedResultsController.delegate = self
    }
    
    
    // MARK: Utility
    
    public subscript(indexPath: NSIndexPath) -> NSManagedObject? {
        return fetchedResultsController.objectAtIndexPath(indexPath) as? NSManagedObject
    }
    
    public func reloadData()
    {
        var error: NSError?
        if !self.fetchedResultsController.performFetch(&error) {
            logger.log("Error performing fetch: \(error!)", forLevel: .Warning)
        } else {
            let fetchedObjects = self.fetchedResultsController.fetchedObjects!
            logger.log("Fetched \(fetchedObjects.count) objects.", forLevel: .Debug)
            logger.log(fetchedObjects, forLevel: .Verbose)
        }
    }
   
}


// MARK: - Table View Datasource

extension FetchedResultsControllerDataSource: UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (fetchedResultsController.sections?[section] as? NSFetchedResultsSectionInfo)?.numberOfObjects ?? 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let element = self[indexPath] {
            if let cellForElement = self.cellForElement {
                return cellForElement(element: element, indexPath: indexPath, tableView: tableView)
            } else {
                let defaultCellIdentifier = "FetchedResultsControllerDataSourceDefaultCellIdentifier" // make class constant
                let cell = UITableViewCell(style: .Default, reuseIdentifier: defaultCellIdentifier)
                // TODO: populate the cell with some information about the element, ideally the element.description
                cell.textLabel?.text = indexPath.description
                return cell
            }
        } else {
            return UITableViewCell()
        }
    }

    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (fetchedResultsController.sections?[section] as? NSFetchedResultsSectionInfo)?.name
    }
    
    public func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        if showSectionIndexTitles {
            return fetchedResultsController.sectionIndexTitles
        } else {
            return nil
        }
    }

    public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return self.fetchedResultsController.sectionForSectionIndexTitle(title, atIndex: index)
    }
    
}


// MARK: - Fetched Results Controller Delegate

extension FetchedResultsControllerDataSource: NSFetchedResultsControllerDelegate {
    
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView?.beginUpdates()
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView?.reloadData()
        tableView?.endUpdates()
    }

    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView?.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
            logger.log("Inserted section with title \(sectionInfo.name) at index \(sectionIndex).", forLevel: .Verbose)
        case .Delete:
            tableView?.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
            logger.log("Deleted section with title \(sectionInfo.name) at index \(sectionIndex).", forLevel: .Verbose)
        default:
            logger.log("Changed section with title \(sectionInfo.name) at index \(sectionIndex) with UNHANDLED type \(type)!", forLevel: .Warning)
            break
        }
    }

    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView?.insertRowsAtIndexPaths([ newIndexPath! ], withRowAnimation: UITableViewRowAnimation.Automatic)
            logger.log("Inserted row for object \(anObject) at index path \(newIndexPath!).", forLevel: .Verbose)
        case .Move:
            tableView?.deleteRowsAtIndexPaths([ indexPath! ], withRowAnimation: .Automatic)
            tableView?.insertRowsAtIndexPaths([ newIndexPath! ], withRowAnimation: UITableViewRowAnimation.Automatic)
            logger.log("Moved row for object \(anObject) from index path \(indexPath!) to \(newIndexPath!).", forLevel: .Verbose)
        case .Delete:
            tableView?.deleteRowsAtIndexPaths([ indexPath! ], withRowAnimation: .Automatic)
            logger.log("Deleted row for object \(anObject) at index path \(indexPath!).", forLevel: .Verbose)
        case .Update:
            if let visibleIndexPaths = tableView?.indexPathsForVisibleRows() as? [NSIndexPath] {
                if contains(visibleIndexPaths, indexPath!) {
                    tableView?.reloadRowsAtIndexPaths([ indexPath! ], withRowAnimation: .Automatic)
                    logger.log("Updated row for object \(anObject) at index path \(indexPath!).", forLevel: .Verbose)
                }
            }
        }
    }
    
}


// MARK: - Logging

extension FetchedResultsControllerDataSource {
    
    public var logger: Logger {
        return Logger.loggerForKeyPath("VIOSFramework.FetchedResultsControllerDataSource")
    }
    
}
