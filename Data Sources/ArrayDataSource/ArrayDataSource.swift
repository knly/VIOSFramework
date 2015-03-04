//
//  ArrayDataSource.swift
//  living
//
//  Created by Nils Fischer on 28.07.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

import Foundation
import UIKit
import VILogKit


// TODO: NSObject inheritance? (necessary to conform to NSObjectProtocol for UITableViewDatasource)
// TODO: Equatable requirement? (necessary for indexPathForElement lookup)

public class ArrayDataSource<T> {
    
    // MARK: Public Properties
    
    /// The Array containing the data.
    public var array: [T]?
    
    /// Closure to sort the elements.
    public var isOrderedBefore: ( (T, T) -> Bool )?
    
    /// Closure to place the elements in sections.
    public var sectionNameForElement: ( T -> String? )?

    /// Closure to filter the elements.
    public var includeElement: ( T -> Bool )?
    
    
    /// Block providing a configured table view cell for a given element
    public var cellForElement: ((element: T, indexPath: NSIndexPath, tableView: UITableView) -> UITableViewCell)?
    
    
    // MARK: Initializers
    
    // TODO: implement more initializers?

    // TODO: really expose initializer without array argument?
    public init() {

    }
    
    public convenience init(array: [T]) {
        self.init()
        self.array = array
    }
    
    
    // MARK: Computed Properties
    
    public private(set) var elements: [T]?
    public private(set) var sections: [VISection<T>]?
    
    public func reloadData() -> [T]?
    {
        logger.log("Loading elements...", forLevel: .Debug)
        
        if let array = self.array {
            let loadingStartDate = NSDate()
            
            var elements = array
            if let includeElement = self.includeElement {
                elements = elements.filter(includeElement)
            }
            if let isOrderedBefore = self.isOrderedBefore {
                elements.sort(isOrderedBefore)
            }
            self.elements = elements
            
            logger.log("\(elements.count) elements loaded in \(NSDate().timeIntervalSinceDate(loadingStartDate))s.", forLevel: .Debug)
            logger.log(elements, forLevel: .Verbose)

            
            if let sectionNameForElement = self.sectionNameForElement {
                logger.log("Sectioning...", forLevel: .Debug)
                let sectioningStartDate = NSDate()

                let sections = VISection.makeSections(elements, sectionNameForElement: sectionNameForElement)
                self.sections = sections
                
                logger.log("Placed \(elements.count) elements into \(sections.count) sections in \(NSDate().timeIntervalSinceDate(sectioningStartDate))s.", forLevel: .Debug)
                logger.log(sections, forLevel: .Verbose)
            } else {
                self.sections = [ VISection(name: nil, elements: elements) ]
            }
            
        } else {
            logger.log("No array provided to load elements from.", forLevel: .Debug)
            self.elements = nil
            self.sections = nil
        }
        
        return self.elements
    }
    
    var sectionIndexTitles: [String]? {
        // TODO: map properly, taking nil into consideration
        if sections?.filter({ $0.indexTitle != nil }).count == 0 {
            return nil
        }
        return sections?.map { (section) -> String in
            return section.indexTitle ?? ""
        }
    }

    
    // MARK: Utility
    
    public subscript(#section: Int, #row: Int) -> T? {
        return self.sections?[section][row: row]
    }

    public subscript(indexPath: NSIndexPath) -> T? {
        return self[section: indexPath.section, row: indexPath.row]
    }
    
    /*
    public subscript(element: T) -> NSIndexPath? {
        if let sections = self.sections {
            for (sectionIndex, section) in enumerate(sections) {
                if let row = find(section.elements, element) {
                    return NSIndexPath(forRow: row, inSection: sectionIndex)
                }
            }
        }
        return nil
    }
    */
    
}


// MARK: - Updating

extension ArrayDataSource {
    
    /*
    public func insert(insertedElements: [T], andUpdateTableView tableView: UITableView?, animated: Bool)
    {
        self.array?.extend(insertedElements)
        reloadData()
        
        if let tableView = tableView {
            let indexPaths = insertedElements.filter { element in
                return self[element] != nil
            }.map { element -> NSIndexPath in
                return self[element]!
            }
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: animated ? .Automatic : .None)
        }
    }
    */

}


// MARK: - Table View Datasource

// TODO: explicitly declare conformation to UITableViewDatasource Protocol
extension ArrayDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        if let sections = self.sections {
            return sections.count
        } else {
            return 0
        }
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let sections = self.sections {
            return sections[section].elements.count
        } else {
            return 0
        }
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if let element = self[indexPath] {
            if let cellForElement = self.cellForElement {
                return cellForElement(element: element, indexPath: indexPath, tableView: tableView)
            } else {
                let defaultCellIdentifier = "ArrayDataSourceDefaultCellIdentifier" // make class constant
                let cell = UITableViewCell(style: .Default, reuseIdentifier: defaultCellIdentifier)
                // TODO: populate the cell with some information about the element, ideally the element.description
                cell.textLabel?.text = indexPath.description
                return cell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return sections?[section].name
    }
    
    public func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]?
    {
        return sectionIndexTitles
    }
    
    public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int
    {
        return index
    }
    
}


// MARK: - Section Class

//TODO: outsource, or define protocol? maybe with identifier property instead of using name to divide into sections
public class VISection<T> {
    
    public let name: String?
    public private(set) var elements: [T]
    
    public required init(name: String?, elements: [T]) {
        self.name = name
        self.elements = elements
    }
    
    // MARK: Sectioning
    
    class func makeSections(elements: [T], sectionNameForElement: (T -> String?) ) -> [VISection<T>]
    {
        var sections = [VISection<T>]()
        
        for element in elements {
            let sectionName = sectionNameForElement(element)
            if sections.last != nil && sections.last!.name == sectionName {
                sections.last!.elements.append(element)
            } else {
                sections.append(self(name: sectionName, elements: [ element ]))
            }
        }
        
        return sections
    }
    
    
    // MARK: Computed Properties
    
    var indexTitle: String? {
        // TODO: replace weird advance() indexing
        return name?.substringToIndex(advance(name!.startIndex, 1)).capitalizedString
    }
    
    
    // MARK: Utility
    
    subscript(#row: Int) -> T {
        return elements[row]
    }
}

extension VISection: Printable, DebugPrintable {
    
    public var description: String {
        let unnamedString = "Unnamed Section" // TODO: make class constant
        return "\(name ?? unnamedString)"
    }

    public var debugDescription: String {
        return "<\(description): \(elements.debugDescription)>"
    }
}


// MARK: - Logging

// TODO: move to umbrella header or sth
public var logger: Logger {
    return Logger.loggerForKeyPath("VIDataSourceKit")
}

extension ArrayDataSource {

    public var logger: Logger {
        return Logger.loggerForKeyPath("VIDataSourceKit.ArrayDataSource")
    }

}

extension VISection {
    
    public var logger: Logger {
        return Logger.loggerForKeyPath("VIDataSourceKit.ArrayDataSource.VISection")
    }
    
}
