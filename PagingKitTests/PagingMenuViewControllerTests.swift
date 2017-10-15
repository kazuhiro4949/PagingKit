//
//  PagingMenuViewControllerTests.swift
//  PagingKitTests
//
//  Copyright (c) 2017 Kazuhiro Hayashi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import XCTest
@testable import PagingKit

class PagingMenuViewControllerTests: XCTestCase {
    
    var dataSource: MenuViewControllerDataSourceSpy?
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        dataSource = nil
        super.tearDown()
    }

    func testScrollBetweenVisibleCells() {
        let dataSource = MenuViewControllerDataSourceSpy()
        let menuViewController = PagingMenuViewControllerTests.makeViewController(with: dataSource)
        dataSource.registerNib(to: menuViewController)
        dataSource.data = Array(repeating: "foo", count: 20)
        dataSource.widthForItem = 100
        
        menuViewController.reloadData()
        
        let indices = menuViewController.visibleCells.flatMap { $0.index }
        let randamizedScrollOrder = (0..<10).map { _ in Int(arc4random_uniform(UInt32(indices.last ?? 0))) }
        var resultOrder = [Int?]()
        for i in randamizedScrollOrder {
            menuViewController.scroll(index: i, animated: false)
            resultOrder.append(menuViewController.currentFocusedCell?.index)
        }
        let actualScrollOrder = resultOrder.flatMap{ $0 }
        XCTAssertEqual(actualScrollOrder, randamizedScrollOrder, "focus correct cell")
    }
    
    func testSelectedIndexIsNillUntilFinishingReloadData() {
        class MenuViewControllerDataMock: NSObject, PagingMenuViewControllerDataSource  {
            var data = Array(repeating: "foo", count: 20)
            var cellForItemHandler: ((PagingMenuViewController) -> Void)?
            
            func registerNib(to vc: PagingMenuViewController) {
                let nib = UINib(nibName: "PagingMenuViewCellStub", bundle: Bundle(for: type(of: self)))
                vc.register(nib: nib, forCellWithReuseIdentifier: "identifier")
            }
            
            func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
                return data.count
            }
            
            func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
                cellForItemHandler?(viewController)
                return viewController.dequeueReusableCell(withReuseIdentifier: "identifier", for: index)
            }
            
            func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
                return 100
            }
        }
        
        let dataSource = MenuViewControllerDataMock()
        let menuViewController = PagingMenuViewControllerTests.makeViewController(with: dataSource)
        dataSource.registerNib(to: menuViewController)
        var readDataCompletion = false
        let expectation = XCTestExpectation(description: "finish load")
        dataSource.cellForItemHandler = { (vc) in
            if !readDataCompletion {
                XCTAssertEqual(vc.currentFocusedIndex, nil, "PagingMenuViewController has no focused index befor reloadData finised")
            }
        }
        menuViewController.reloadData(with: 3) { (_) in
            readDataCompletion = true
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testSelectedIndexIsNotNilAfterFinishingReloadData() {
        class MenuViewControllerDataMock: NSObject, PagingMenuViewControllerDataSource  {
            var data = Array(repeating: "foo", count: 20)
            var cellForItemHandler: ((PagingMenuViewController) -> Void)?
            
            func registerNib(to vc: PagingMenuViewController) {
                let nib = UINib(nibName: "PagingMenuViewCellStub", bundle: Bundle(for: type(of: self)))
                vc.register(nib: nib, forCellWithReuseIdentifier: "identifier")
            }
            
            func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
                return data.count
            }
            
            func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
                cellForItemHandler?(viewController)
                return viewController.dequeueReusableCell(withReuseIdentifier: "identifier", for: index)
            }
            
            func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
                return 100
            }
        }
        
        let dataSource = MenuViewControllerDataMock()
        let menuViewController = PagingMenuViewControllerTests.makeViewController(with: dataSource)
        dataSource.registerNib(to: menuViewController)
        var readDataCompletion = false
        let expectation = XCTestExpectation(description: "finish load")
        dataSource.cellForItemHandler = { (vc) in
            if readDataCompletion {
                XCTAssertEqual(vc.currentFocusedIndex, 3, "PagingMenuViewController has no focused index befor reloadData finised")
            }
        }
        menuViewController.reloadData(with: 3) { (_) in
            readDataCompletion = true
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    static func makeViewController(with dataSource: PagingMenuViewControllerDataSource) -> PagingMenuViewController {
        let menuViewController = PagingMenuViewController(nibName: nil, bundle: nil)
        menuViewController.dataSource = dataSource
        menuViewController.loadViewIfNeeded()
        return menuViewController
    }
}

class MenuViewControllerDataSourceSpy: NSObject, PagingMenuViewControllerDataSource  {
    var data = [String]()
    var widthForItem: CGFloat = 0
    
    func registerNib(to vc: PagingMenuViewController) {
        let nib = UINib(nibName: "PagingMenuViewCellStub", bundle: Bundle(for: type(of: self)))
        vc.register(nib: nib, forCellWithReuseIdentifier: "identifier")
    }

    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return data.count
    }
    
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        return viewController.dequeueReusableCell(withReuseIdentifier: "identifier", for: index)
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        return widthForItem
    }
}
