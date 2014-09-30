//
//  VIArrayDataSourceTests.swift
//  VIOSFramework
//
//  Created by Nils Fischer on 17.08.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

import XCTest

class VIArrayDataSourceTests: XCTestCase {

    var array = [ VIPerson(firstName: "Xavier", lastName: "Bob"), VIPerson(firstName: "Alice", lastName: nil), VIPerson(), VIPerson(firstName: nil, lastName: "Chen"), VIPerson(firstName: "David", lastName: "Drey") ]


    func testLoadingObjects() {
        let arrayDataSource = VIArrayDataSource(array: array)
        let objects = arrayDataSource.objects
        XCTAssertEqual(objects.count, array.count, "Object array and source array don't have the same number of elements")
        for i in 0..<objects.count {
            XCTAssert(objects[i] === array[i], "Object \(objects[i]) at index \(i) is not the same as the corresponding object \(array[i]) in the source array.")
        }
    }
    
    func testLoadingSortedObjects() {
        let isOrderedBefore = VIPerson.leadingLastNameIsOrderedBefore
        let arrayDataSource = VIArrayDataSource(array: array)
        arrayDataSource.isOrderedBefore = isOrderedBefore
        let objects = arrayDataSource.objects
        for i in 0..<objects.count {
            XCTAssert(objects[i] === array.sorted(isOrderedBefore)[i], "Object \(objects[i]) at index \(i) is not the same as the corresponding object \(array[i]) in the sorted source array.")
        }
    }
    
    func testLoadingSections() {
        let isOrderedBefore = VIPerson.leadingLastNameIsOrderedBefore
        let sectionNameForObject = VIPerson.leadingLastNameInitial
        let arrayDataSource = VIArrayDataSource(array: array)
        arrayDataSource.isOrderedBefore = isOrderedBefore
        arrayDataSource.sectionNameForObject = sectionNameForObject
        let objects = arrayDataSource.objects
        let sections = arrayDataSource.sections
        for section in sections {
            for object in section.objects {
                XCTAssert(section.name == sectionNameForObject(object), "Object's section name does not match the section's name it was placed in.")
            }
        }
    }

}
