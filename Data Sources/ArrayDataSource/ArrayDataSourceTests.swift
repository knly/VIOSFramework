//
//  ArrayDataSourceTests.swift
//  VIOSFramework
//
//  Created by Nils Fischer on 17.08.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

import XCTest
import VIDataSourceKit

class ArrayDataSourceTests: XCTestCase {

    let array = [ "Alice", "Dave", "Bob" ]
    
    // TODO: fix segmentation faults
    
    //let isOrderedBefore: (String, String) -> Bool = { return $0 < $1 }
    /*let sectionNameForObject = { (obj: String) -> String in
        return ""
        //return (obj as NSString).substringToIndex(1).capitalizedString // use swift stdlib
    }*/

    func testLoadingElements() {
        let arrayDataSource = ArrayDataSource(array: array)
        arrayDataSource.reloadData()
        if let elements = arrayDataSource.elements {
            XCTAssertEqual(elements.count, array.count, "Element array and source array don't have the same number of elements")
            for i in 0..<elements.count {
                XCTAssert(elements[i] == array[i], "Element \(elements[i]) at index \(i) is not the same as the corresponding element \(array[i]) in the source array.")
            }
        } else {
            XCTAssert(false, "Elements could not be loaded.")
        }
    }
    
    /*func testLoadingSortedObjects() {
        let arrayDataSource = ArrayDataSource(array: array)
        arrayDataSource.isOrderedBefore = isOrderedBefore
        let objects = arrayDataSource.objects
        for i in 0..<objects.count {
            XCTAssert(objects[i] == array.sorted(isOrderedBefore)[i], "Object \(objects[i]) at index \(i) is not the same as the corresponding object \(array[i]) in the sorted source array.")
        }
    }*/
    
    /*func testLoadingSections() {
        let arrayDataSource = ArrayDataSource(array: array)
        arrayDataSource.isOrderedBefore = isOrderedBefore
        arrayDataSource.sectionNameForObject = sectionNameForObject
        let objects = arrayDataSource.objects
        let sections = arrayDataSource.sections
        for section in sections {
            for object in section.objects {
                XCTAssert(section.name == sectionNameForObject(object), "Object's section name does not match the section's name it was placed in.")
            }
        }
    }*/

}
