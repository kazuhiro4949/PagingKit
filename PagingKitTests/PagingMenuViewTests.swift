//
//  PagingMenuViewTests.swift
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

class PagingMenuViewTests: XCTestCase {
    
    var pagingMenuView: PagingMenuView?
    
    override func setUp() {
        super.setUp()
        pagingMenuView = PagingMenuView(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCallingDataSource() {
        class MenuViewDataSourceMock: NSObject, PagingMenuViewDataSource  {
            var data = [String]()
            var numberOfSectionExpectation = XCTestExpectation(description: "call numberOfItemForPagingMenuView()")
            var widthForItemExpectation = XCTestExpectation(description: "call pagingMenuView(pagingMenuView:,widthForItemAt:)")
            var cellForItemExpectation = XCTestExpectation(description: "call pagingMenuView(pagingMenuView:,cellForItemAt:)")
            
            public func numberOfItemForPagingMenuView() -> Int {
                numberOfSectionExpectation.fulfill()
                return data.count
            }
            
            public func pagingMenuView(pagingMenuView: PagingMenuView, widthForItemAt index: Int) -> CGFloat {
                widthForItemExpectation.fulfill()
                return 100
            }
            
            public func pagingMenuView(pagingMenuView: PagingMenuView, cellForItemAt index: Int) -> PagingMenuViewCell {
                cellForItemExpectation.fulfill()
                return PagingMenuViewCell()
            }
        }
        
        let dataSource = MenuViewDataSourceMock()
        dataSource.data = Array(repeating: "foo", count: 20)
        pagingMenuView?.dataSource = dataSource
        pagingMenuView?.reloadData()
        wait(for: [dataSource.numberOfSectionExpectation, dataSource.widthForItemExpectation, dataSource.cellForItemExpectation], timeout: 0)
    }
    
    func testRegisterNibAndDequeue() {
        let nib = UINib(nibName: "PagingMenuViewCellStub", bundle: Bundle(for: type(of: self)))
        let identifier = "identifier"
        pagingMenuView?.register(nib: nib, with: identifier)
        let cell = pagingMenuView?.dequeue(with: identifier)
        XCTAssertEqual(cell?.identifier, identifier, "get correct cell")
    }
    
    func testIndexForItem() {
        let dataSource = MenuViewDataSourceSpy()
        dataSource.widthForItem = 100
        dataSource.registerNib(to: pagingMenuView)
        dataSource.data = Array(repeating: "foo", count: 20)
        pagingMenuView?.dataSource = dataSource
        pagingMenuView?.reloadData()
        
        let index = pagingMenuView?.indexForItem(at: CGPoint(x: 320, y: 0))
        XCTAssertEqual(index, 3, "get correct index from method")
    }
    
    func testCellForItem() {
        let dataSource = MenuViewDataSourceSpy()
        dataSource.widthForItem = 100
        dataSource.registerNib(to: pagingMenuView)
        dataSource.data = Array(repeating: "foo", count: 20)
        pagingMenuView?.dataSource = dataSource
        pagingMenuView?.reloadData()
        
        do {
            let cell = pagingMenuView?.cellForItem(at: 1)
            XCTAssertEqual(cell?.index, 1, "get correct cell")
        }

        do {
            let cell = pagingMenuView?.cellForItem(at: 19)
            XCTAssertEqual(cell?.index, nil, "cell is nil because of not visible")
        }
    }

    func testRectForItem() {
        let dataSource = MenuViewDataSourceSpy()
        dataSource.widthForItem = 100
        dataSource.registerNib(to: pagingMenuView)
        dataSource.data = Array(repeating: "foo", count: 20)
        pagingMenuView?.dataSource = dataSource
        pagingMenuView?.reloadData()
        
        let rect = pagingMenuView?.rectForItem(at: 3)
        XCTAssertEqual(rect,
                       CGRect(x: 300, y: 0, width: 100, height: 44), "get correct rect")
    }
    
    func testRectForItemToEdgeCase() {
        let dataSource = MenuViewDataSourceSpy()
        dataSource.widthForItem = 100
        dataSource.registerNib(to: pagingMenuView)
        dataSource.data = Array(repeating: "foo", count: 20)
        pagingMenuView?.dataSource = dataSource
        pagingMenuView?.reloadData()
        
        let rect = pagingMenuView?.rectForItem(at: 20)
        XCTAssertEqual(rect,
                       CGRect(x: 2000, y: 0, width: 0, height: 44), "get correct rect")
    }
    
    func testRectForItems() {
        guard let pagingMenuView = pagingMenuView else {
            XCTFail("pagingMenuView is not nil")
            return
        }
        
        let dataSource = MenuViewDataSourceSpy()
        dataSource.widthForItem = 100
        dataSource.registerNib(to: pagingMenuView)
        dataSource.data = Array(repeating: "foo", count: 20)
        pagingMenuView.dataSource = dataSource
        pagingMenuView.reloadData()
        
        let actualRects = (0..<dataSource.data.count).flatMap(pagingMenuView.rectForItem)
        let expectedRects = Array(stride(from: 0, to: 2000, by: 100)).map { CGRect(x: $0, y: 0, width: 100, height: 44) }
        XCTAssertEqual(actualRects,
                       expectedRects, "get correct rect")
    }
    
    func testInvalidateLayout() {
        let dataSource = MenuViewDataSourceSpy()
        dataSource.widthForItem = 100
        dataSource.registerNib(to: pagingMenuView)
        dataSource.data = Array(repeating: "foo", count: 20)
        pagingMenuView?.dataSource = dataSource
        pagingMenuView?.reloadData()
        
        let resizedWidth: CGFloat = 20
        dataSource.widthForItem = resizedWidth
        pagingMenuView?.invalidateLayout()
        
        XCTAssertEqual(pagingMenuView?.contentSize.width, 400, "success to change content layout")
        
        guard let widths = pagingMenuView?.visibleCells.map({ $0.bounds.width }) else {
            XCTFail("pagingMenuView needs to have visible cells")
            return
        }
        
        let expectedWidths = widths.map { _ in resizedWidth }
        XCTAssertEqual(widths, expectedWidths, "dataSource has resized cells")
    }
}

class MenuViewDataSourceSpy: NSObject, PagingMenuViewDataSource  {
    var data = [String]()
    var widthForItem: CGFloat = 0
    
    func registerNib(to view: PagingMenuView?) {
        let nib = UINib(nibName: "PagingMenuViewCellStub", bundle: Bundle(for: type(of: self)))
        view?.register(nib: nib, with: "identifier")
    }
    
    public func numberOfItemForPagingMenuView() -> Int {
        return data.count
    }
    
    public func pagingMenuView(pagingMenuView: PagingMenuView, widthForItemAt index: Int) -> CGFloat {
        return widthForItem
    }
    
    public func pagingMenuView(pagingMenuView: PagingMenuView, cellForItemAt index: Int) -> PagingMenuViewCell {
        return pagingMenuView.dequeue(with: "identifier")
    }
}
