//
//  VIArrayDataSource.swift
//  living
//
//  Created by Nils Fischer on 28.07.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

import Foundation
import UIKit

// TODO: remove NSObject inheritance (needed to conform to NSObjectProtocol for UITableViewDatasource)
// TODO: rename object to element

public class VIArrayDataSource<T>: NSObject {
    
    // MARK: Public Properties
    
    /// The Array containing the data
    public var array: [T]? {
        didSet {
            setNeedsReload()
        }
    }
    
    /// Closure to sort the resulting objects
    // TODO: rename?
    public var isOrderedBefore: ( (T, T) -> Bool )? {
        didSet {
            setNeedsReload()
        }
    }
    
    /// Closure used for dividing resulting objects into sections
    // TODO: rename?
    public var sectionNameForObject: ( T -> String? )? {
        didSet {
            setNeedsReload()
        }
    }
    
    public var includeObject: ( T -> Bool )? {
        didSet {
            setNeedsReload()
        }
    }
    
    //TODO: outsource cell block definition
    /// Block providing a configured table view cell for a given object
    public typealias DequeueAndConfigureCellBlock = (tableView: UITableView, indexPath: NSIndexPath, object: T) -> UITableViewCell
    public var cellBlock: DequeueAndConfigureCellBlock? {
        didSet {
            // TODO: reload something
        }
    }
    
    
    // MARK: Initializers
    
    // TODO: implement more initializers?

    // TODO: really expose initializer without array argument?
    public override init() {

    }
    
    public convenience init(array: [T]) {
        self.init()
        self.array = array
    }
    
    
    // MARK: Computed Properties
    
    // TODO: use lazy properties
    
    public var objects: [T] {
        if _objects == nil {
            _objects = loadObjects()
        }
        return _objects!
    }
    private var _objects: [T]?
    
    private func loadObjects() -> [T]
    {
        if let array = array {
            var objects = array
            if let includeObject = self.includeObject {
                objects = objects.filter(includeObject)
            }
            if let isOrderedBefore = self.isOrderedBefore {
                objects.sort(isOrderedBefore)
            }
            return objects
        } else {
            return []
        }
    }
    
    public var sections: [VISection<T>] {
        if _sections == nil {
            _sections = loadSections()
        }
        return _sections!
    }
    private var _sections: [VISection<T>]?
    
    private func loadSections() -> [VISection<T>]
    {
        if let sectionNameForObject = sectionNameForObject {
            return VISection<T>.makeSections(objects, sectionNameForObject: sectionNameForObject)
        } else {
            return [ VISection<T>(name: nil, objects: objects) ]
        }
    }
    
    var sectionIndexTitles: [String] {
        var titles = [String]()
        for section in sections {
            //TODO: what about nil indexTitles?
            if let title = section.indexTitle {
                titles.append(title)
            }
        }
        return titles
    }

    
    // MARK: Trigger Reload
    
    private func setNeedsReload()
    {
        _objects = nil
        _sections = nil
    }
    
    
    // MARK: Utility
    
    public subscript(section: Int, row: Int) -> T {
        return sections[section][row]
    }

    public subscript(indexPath: NSIndexPath) -> T {
        return objectAtIndexPath(indexPath)
    }

    public func objectAtIndexPath(indexPath: NSIndexPath) -> T
    {
        return self[indexPath.section, indexPath.row]
    }
    
}


// MARK: - Table View Datasource

// TODO: explicitly declare conformation to UITableViewDatasource Protocol
extension VIArrayDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView!) -> Int
    {
        return sections.count
    }
    
    public func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        return sections[section].objects.count
    }
    
    public func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        if let cellBlock = self.cellBlock {
            return cellBlock(tableView: tableView, indexPath: indexPath, object: objectAtIndexPath(indexPath))
        } else {
            return nil
        }
    }
    
    public func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String?
    {
        return sections[section].name
    }
    
    public func sectionIndexTitlesForTableView(tableView: UITableView!) -> [String]
    {
        return sectionIndexTitles
    }
    
    public func tableView(tableView: UITableView!, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int
    {
        return index
    }
    
}


// MARK: - Section


//TODO: outsource, or define protocol? maybe with identifier property instead of using name to divide into sections
public struct VISection<T> {
    
    let name: String?
    let objects: [T]
    
    // MARK: Sectioning
    
    static func makeSections(objects: [T], sectionNameForObject: T -> String? ) -> [VISection<T>]
    {
        /*var sectionDict = [ String : [T] ]()
        var emptySectionObjects = [T]()
        for object in objects {
            if let sectionName = sectionNameForObject(object) {
                if var sectionObjects = sectionDict[sectionName] {
                    sectionObjects.append(object)
                } else {
                    sectionDict[sectionName] = [ object ]
                }
            } else {
                emptySectionObjects.append(object)
            }
        }

        var sections = [VISection<T>]()
        for ( sectionName, sectionObjects ) in sectionDict {
            sections.append(VISection(name: sectionName, objects: sectionObjects))
        }
        if emptySectionObjects.count > 0 {
            sections.append(VISection(name: nil, objects: emptySectionObjects))
        }*/
        
        var sections = [VISection<T>]()
        
        if objects.count == 0 {
            return sections
        }
        
        var sectionObjects = [T]()
        var sectionName = sectionNameForObject(objects.first!)
        for object in objects {
            let objSectionName = sectionNameForObject(object)
            if !(objSectionName == nil && sectionName == nil || objSectionName != nil && sectionName != nil && objSectionName! == sectionName!) {
                sections.append(VISection(name: sectionName, objects: sectionObjects))
                sectionName = objSectionName
                sectionObjects = []
            }
            sectionObjects.append(object)
        }
        sections.append(VISection(name: sectionName, objects: sectionObjects))

        return sections
    }
    
    
    // MARK: Computed Properties
    
    var indexTitle: String? {
        // TODO: replace weird advance() indexing
        return name?.substringToIndex(advance(name!.startIndex, 1)).capitalizedString
    }
    
    
    // MARK: Utility
    
    subscript(row: Int) -> T {
        return objects[row]
    }
}

extension VISection: Printable {
    
    public var description: String {
        let unnamedString = "Unnamed Section"
        return "<\(name ?? unnamedString): \(objects.description)>"
    }
}
