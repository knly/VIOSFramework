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

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLoadingObjects() {
        let arrayDataSource = VIArrayDataSource(array: array)
        let objects = arrayDataSource.objects
        XCTAssertEqual(objects.count, array.count, "Object array and source array don't have the same number of elements")
        for i in 0..<objects.count {
            XCTAssertEqual(objects[i], array[i], "Object \(objects[i]) at index \(i) is not the same as the corresponding object \(array[i]) in the source array.")
        }
    }
    
    func testLoadingSortedObjects() {
        let isOrderedBefore = VIPerson.leadingLastNameIsOrderedBefore
        let arrayDataSource = VIArrayDataSource(array: array)
        arrayDataSource.isOrderedBefore = isOrderedBefore
        let objects = arrayDataSource.objects
        for i in 0..<objects.count {
            XCTAssertEqual(objects[i], array.sorted(isOrderedBefore)[i], "Object \(objects[i]) at index \(i) is not the same as the corresponding object \(array[i]) in the sorted source array.")
        }
    }
    
    func testLoadingSections() {
        let arrayDataSource = VIArrayDataSource(array: array)
        arrayDataSource.isOrderedBefore = VIPerson.leadingLastNameIsOrderedBefore
        println(arrayDataSource.sections)
        arrayDataSource.sectionNameForObject = VIPerson.leadingLastNameInitial
        println(arrayDataSource.sections)
    }
    
}
