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
    var menuViewController: PagingMenuViewController?
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        dataSource = nil
        menuViewController = nil
        super.tearDown()
    }
    
    func testRloadDataWithNoIndex() {
        let dataSource = MenuViewControllerDataSourceSpy()
        menuViewController = PagingMenuViewControllerTests.makeViewController(with: dataSource)
        menuViewController?.view.frame = CGRect(x: 0, y: 0, width: 460, height: 44)
        dataSource.registerNib(to: menuViewController)
        dataSource.data = Array(repeating: "foo", count: 20)
        dataSource.widthForItem = 100
        
        let expectation = XCTestExpectation(description: "timeout")
        menuViewController?.reloadData() { [weak menuViewController] _ in
            XCTAssertEqual(menuViewController?.menuView.contentSize, CGSize(width: 2000, height: 44), "expected scrvollView layout")
            XCTAssertEqual(menuViewController?.menuView.contentOffset, CGPoint(x: 0, y: 0), "expected offset")
            expectation.fulfill()
        }
        menuViewController?.view.setNeedsLayout()
        menuViewController?.view.layoutIfNeeded()
        wait(for: [expectation], timeout: 2)
    }
    
    func testRloadDataWithIndex() {
        let dataSource = MenuViewControllerDataSourceSpy()
        menuViewController = PagingMenuViewControllerTests.makeViewController(with: dataSource)
        menuViewController?.view.frame = CGRect(x: 0, y: 0, width: 460, height: 44)
        dataSource.registerNib(to: menuViewController)
        dataSource.data = Array(repeating: "foo", count: 20)
        dataSource.widthForItem = 100
        
        let expectation = XCTestExpectation(description: "timeout")
        menuViewController?.reloadData(with: 1) { [weak menuViewController] _ in
            XCTAssertEqual(menuViewController?.currentFocusedIndex, 1, "expected index")
            expectation.fulfill()
        }
        menuViewController?.view.setNeedsLayout()
        menuViewController?.view.layoutIfNeeded()
        wait(for: [expectation], timeout: 2)
    }
    
    func testRloadDataWithIndexAndNoIndex() {
        let dataSource = MenuViewControllerDataSourceSpy()

        menuViewController = PagingMenuViewControllerTests.makeViewController(with: dataSource)
        menuViewController?.view.frame = CGRect(x: 0, y: 0, width: 460, height: 44)
        dataSource.registerNib(to: menuViewController)
        dataSource.data = Array(repeating: "foo", count: 20)
        dataSource.widthForItem = 100
        
        let expectation = XCTestExpectation(description: "timeout")
        menuViewController?.reloadData(with: 1) { [weak menuViewController] _ in
            menuViewController?.reloadData() { [weak menuViewController] _ in
                XCTAssertEqual(menuViewController?.currentFocusedIndex, 1, "expected index")
                expectation.fulfill()
            }
            menuViewController?.view.setNeedsLayout()
            menuViewController?.view.layoutIfNeeded()
        }
        menuViewController?.view.setNeedsLayout()
        menuViewController?.view.layoutIfNeeded()
        wait(for: [expectation], timeout: 2)
    }
    
    func testRloadDataWithIndexAndIndexAgain() {
        let dataSource = MenuViewControllerDataSourceSpy()
        
        menuViewController = PagingMenuViewControllerTests.makeViewController(with: dataSource)
        menuViewController?.view.frame = CGRect(x: 0, y: 0, width: 460, height: 44)
        dataSource.registerNib(to: menuViewController)
        dataSource.data = Array(repeating: "foo", count: 20)
        dataSource.widthForItem = 100
        
        let expectation = XCTestExpectation(description: "timeout")
        menuViewController?.reloadData(with: 1) { [weak menuViewController] _ in
            menuViewController?.reloadData(with: 3) { [weak menuViewController] _ in
                XCTAssertEqual(menuViewController?.currentFocusedIndex, 3, "expected index")
                expectation.fulfill()
            }
            menuViewController?.view.setNeedsLayout()
            menuViewController?.view.layoutIfNeeded()
        }
        menuViewController?.view.setNeedsLayout()
        menuViewController?.view.layoutIfNeeded()
        wait(for: [expectation], timeout: 2)
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
    
    func testHookCompletionHandlerAfterReloadData() {
        let dataSource = MenuViewControllerDataSourceMock()
        let menuViewController = PagingMenuViewControllerTests.makeViewController(with: dataSource)
        dataSource.registerNib(to: menuViewController)
        
        let expectation = XCTestExpectation(description: "finish load")
        menuViewController.reloadData(with: 15) { [menuViewController = menuViewController] (_) in
            let minX = menuViewController.menuView.rectForItem(at: 15).midX
            let expectedContentOffsetX = minX - floor(menuViewController.menuView.bounds.width / 2)
            XCTAssertEqual(
                menuViewController.menuView.contentOffset,
                CGPoint(x: expectedContentOffsetX, y: 0),
                "PagingMenuViewController has completely finished reloading"
            )
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testSelectedIndexIsNotNilDuringReloadData() {
        let dataSource = MenuViewControllerDataSourceMock()
        let menuViewController = PagingMenuViewControllerTests.makeViewController(with: dataSource)
        dataSource.registerNib(to: menuViewController)
        var readDataCompletion = false
        let expectation = XCTestExpectation(description: "finish load")
        dataSource.cellForItemHandler = { (vc) in
            if !readDataCompletion {
                XCTAssertEqual(vc.currentFocusedIndex, 3, "PagingMenuViewController has focused index befor reloadData finised")
            }
        }
        menuViewController.reloadData(with: 3) { (_) in
            readDataCompletion = true
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testSelectedIndexIsNotNilAfterFinishingReloadData() {
        let dataSource = MenuViewControllerDataSourceMock()
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
    
    func testRegisterFocusViewWithXib() {
        let menuViewController = PagingMenuViewControllerTests.makeViewController(with: MenuViewControllerDataSourceSpy())
        menuViewController.registerFocusView(nib: UINib(nibName: "PagingMenuFocusView", bundle: Bundle(for: type(of: self))))
        XCTAssertEqual(menuViewController.focusView.subviews.count, 1, "registered custom focus view")
        XCTAssertTrue(menuViewController.focusView.subviews.first is PagingMenuFocusView, "registered custom focus view")
    }
    
    func testRegisterFocusViewWithObj() {
        let menuViewController = PagingMenuViewControllerTests.makeViewController(with: MenuViewControllerDataSourceSpy())
        menuViewController.registerFocusView(view: PagingMenuFocusView())
        XCTAssertEqual(menuViewController.focusView.subviews.count, 1, "registered custom focus view")
        XCTAssertTrue(menuViewController.focusView.subviews.first is PagingMenuFocusView, "registered custom focus view")
    }
    
    func testRegisterFocusViewWithZposition() {
        let menuViewController = PagingMenuViewControllerTests.makeViewController(with: MenuViewControllerDataSourceSpy())
        menuViewController.registerFocusView(nib: UINib(nibName: "PagingMenuFocusView", bundle: Bundle(for: type(of: self))), isBehindCell: true)
        XCTAssertEqual(menuViewController.focusView.subviews.count, 1, "registered custom focus view")
        XCTAssertTrue(menuViewController.focusView.subviews.first is PagingMenuFocusView, "registered custom focus view")
        XCTAssertEqual(menuViewController.focusView.layer.zPosition, -1, "registered custom focus view with -1 zPosition")
    }
    
    func testInvalidateLayout() {
        let expection = XCTestExpectation(description: "waiting for reloading")
        let dataSource = MenuViewControllerDataSourceMock()
        let menuViewController = PagingMenuViewControllerTests.makeViewController(with: dataSource)
        dataSource.registerNib(to: menuViewController)
        
        menuViewController.loadViewIfNeeded()
        menuViewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 44)
        menuViewController.reloadData(with: 0) { _ in
            let resizedLength: CGFloat = 20
            dataSource.widthForItem = resizedLength
            menuViewController.view.frame.size.height = resizedLength
            menuViewController.invalidateLayout()
            let cellFrames = menuViewController.visibleCells.map { $0.frame }
            let expectedCellFrames = (0..<cellFrames.count).reduce([CGRect]()) { (sum, rect) in
                let lastRect = sum.last ?? .zero
                let nextRect = CGRect(x: lastRect.maxX, y: 0, width: resizedLength, height: resizedLength)
                return sum + [nextRect]
            }
            XCTAssertEqual(cellFrames, expectedCellFrames, "dataSource has resized cells")
            XCTAssertEqual(resizedLength, menuViewController.menuView.contentSize.height, "dataSource has resized cells")
            expection.fulfill()
        }
        wait(for: [expection], timeout: 1.0)
    }
    
    func testChangeMenuCellWidthAfterReload() {
        let dataSource = MenuViewControllerDataSourceMock()
        let menuViewController = PagingMenuViewControllerTests.makeViewController(with: dataSource)
        dataSource.registerNib(to: menuViewController)
        
        let expectation = XCTestExpectation(description: "finish load")
        menuViewController.reloadData(with: 0) { [menuViewController = menuViewController] (_) in
            let newCellWidth: CGFloat = 200
            dataSource.widthForItem = newCellWidth
            menuViewController.reloadData(with: 0) { [menuViewController = menuViewController] (_) in
                XCTAssertEqual(menuViewController.focusView.bounds.width, 200, "focusView.frame.width is equal to cell width")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2)
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
    
    func registerNib(to vc: PagingMenuViewController?) {
        let nib = UINib(nibName: "PagingMenuViewCellStub", bundle: Bundle(for: type(of: self)))
        vc?.register(nib: nib, forCellWithReuseIdentifier: "identifier")
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

class MenuViewControllerDataSourceMock: NSObject, PagingMenuViewControllerDataSource  {
    var data = Array(repeating: "foo", count: 20)
    var widthForItem: CGFloat = 100
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
        return widthForItem
    }
}
