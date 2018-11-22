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
        
        let actualRects = (0..<dataSource.data.count).compactMap(pagingMenuView.rectForItem)
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
    
    func testFocusViewFrameWhenZeroInsets() {
        let dataSource = MenuViewDataSourceSpy()
        dataSource.widthForItem = 100
        dataSource.registerNib(to: pagingMenuView)
        dataSource.data = Array(repeating: "foo", count: 20)
        pagingMenuView?.dataSource = dataSource
        pagingMenuView?.reloadData()
        
        
        do {
            let expectation = XCTestExpectation(description: "index: 0")
            pagingMenuView?.scroll(index: 0, completeHandler: { [weak self] _ in
                let frame = CGRect(x: 0, y: 0, width: 100, height: 44)
                XCTAssertEqual(self?.pagingMenuView?.focusView.frame, frame, "success to change content layout")
                expectation.fulfill()
            })
            wait(for: [expectation], timeout: 1)
        }
        
        do {
            let expectation = XCTestExpectation(description: "index: 19")
            pagingMenuView?.scroll(index: 19, completeHandler: { [weak self] _ in
                let frame = CGRect(x: 1900, y: 0, width: 100, height: 44)
                XCTAssertEqual(self?.pagingMenuView?.focusView.frame, frame, "success to change content layout")
                expectation.fulfill()
            })
            wait(for: [expectation], timeout: 2)
        }
        
        do {
            let expectation = XCTestExpectation(description: "index: 9")
            pagingMenuView?.scroll(index: 9, completeHandler: { [weak self] _ in
                let frame = CGRect(x: 900, y: 0, width: 100, height: 44)
                XCTAssertEqual(self?.pagingMenuView?.focusView.frame, frame, "success to change content layout")
                expectation.fulfill()
            })
            wait(for: [expectation], timeout: 2)
        }
    }
    
    func testFocusViewFrameWhenNonZeroInsets() {
        let dataSource = MenuViewDataSourceSpy()
        dataSource.widthForItem = 100
        dataSource.registerNib(to: pagingMenuView)
        dataSource.data = Array(repeating: "foo", count: 20)
        pagingMenuView?.dataSource = dataSource
        pagingMenuView?.reloadData()
        pagingMenuView?.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        do {
            let expectation = XCTestExpectation(description: "index: 0")
            pagingMenuView?.scroll(index: 0, completeHandler: { [weak self] _ in
                let frame = CGRect(x: 0, y: 0, width: 100, height: 44)
                XCTAssertEqual(self?.pagingMenuView?.focusView.frame, frame, "success to change content layout")
                expectation.fulfill()
            })
            wait(for: [expectation], timeout: 1)
        }
        
        do {
            let expectation = XCTestExpectation(description: "index: 19")
            pagingMenuView?.scroll(index: 19, completeHandler: { [weak self] _ in
                let frame = CGRect(x: 1900, y: 0, width: 100, height: 44)
                XCTAssertEqual(self?.pagingMenuView?.focusView.frame, frame, "success to change content layout")
                expectation.fulfill()
            })
            wait(for: [expectation], timeout: 2)
        }
        
        do {
            let expectation = XCTestExpectation(description: "index: 9")
            pagingMenuView?.scroll(index: 9, completeHandler: { [weak self] _ in
                let frame = CGRect(x: 900, y: 0, width: 100, height: 44)
                XCTAssertEqual(self?.pagingMenuView?.focusView.frame, frame, "success to change content layout")
                expectation.fulfill()
            })
            wait(for: [expectation], timeout: 2)
        }
    }
    
    func testFocusViewIsInFrontOfPagingMenuViewCells() {
        guard let pagingMenuView = pagingMenuView else {
            XCTFail()
            return
        }
        
        let dataSource = MenuViewDataSourceSpy()
        dataSource.widthForItem = 100
        dataSource.registerNib(to: pagingMenuView)
        dataSource.data = Array(repeating: "foo", count: 20)
        pagingMenuView.dataSource = dataSource
        pagingMenuView.reloadData()
        pagingMenuView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        do {
            let expectation = XCTestExpectation(description: "index: 0")
            pagingMenuView.scroll(index: 0, completeHandler: { _ in
                guard let focusViewIndex = pagingMenuView.containerView.subviews.index(of: pagingMenuView.focusView) else {
                    XCTFail()
                    return
                }
                
                let cellIndice = pagingMenuView
                    .visibleCells
                    .compactMap(pagingMenuView.containerView.subviews.index(of:))
                
                let aboveIndices = cellIndice.filter { Int($0) > Int(focusViewIndex) }
                XCTAssertEqual(aboveIndices.count, 0, "focus view is in front of cell")
                expectation.fulfill()
            })
            wait(for: [expectation], timeout: 1)
        }
        
        do {
            let expectation = XCTestExpectation(description: "index: 19")
            pagingMenuView.scroll(index: 19, completeHandler: { _ in
                guard let focusViewIndex = pagingMenuView.containerView.subviews.index(of: pagingMenuView.focusView) else {
                    XCTFail()
                    return
                }
                
                let cellIndice = pagingMenuView
                    .visibleCells
                    .compactMap(pagingMenuView.containerView.subviews.index(of:))
                
                let aboveIndices = cellIndice.filter { Int($0) > Int(focusViewIndex) }
                XCTAssertEqual(aboveIndices.count, 0, "focus view is in front of cell")
                expectation.fulfill()
            })
            wait(for: [expectation], timeout: 1)
        }
    }
    
    func testCellAlignment() {
        guard let pagingMenuView = pagingMenuView else {
            XCTFail("pagingMenuView is not nil")
            return
        }
        
        do {
            let dataSource = MenuViewDataSourceSpy()
            dataSource.widthForItem = 50
            dataSource.registerNib(to: pagingMenuView)
            dataSource.data = Array(repeating: "foo", count: 3)
            pagingMenuView.dataSource = dataSource
            
            pagingMenuView.reloadData()
            XCTAssertEqual(
                pagingMenuView.containerView.frame.origin.x,
                0,
                "aligning on the left side")
            
            pagingMenuView.cellAlignment = .right
            pagingMenuView.reloadData()
            XCTAssertEqual(
                pagingMenuView.containerView.frame.origin.x,
                pagingMenuView.bounds.width - pagingMenuView.containerView.bounds.width,
                "aligning on the right side")
            
            pagingMenuView.cellAlignment = .center
            pagingMenuView.reloadData()
            XCTAssertEqual(
                pagingMenuView.containerView.frame.origin.x,
                (pagingMenuView.bounds.width - pagingMenuView.containerView.bounds.width) / 2,
                "centering")
        }

        do {
            let dataSource = MenuViewDataSourceSpy()
            dataSource.widthForItem = 100
            dataSource.registerNib(to: pagingMenuView)
            dataSource.data = Array(repeating: "foo", count: 20)
            pagingMenuView.dataSource = dataSource
            pagingMenuView.cellAlignment = .center
            pagingMenuView.reloadData()
            XCTAssertEqual(
                pagingMenuView.containerView.frame.origin.x,
                0,
                "not applying cellAlignment")
        }
    }
    
    func testSelectedCell() {
        guard let pagingMenuView = pagingMenuView else {
            XCTFail("pagingMenuView is not nil")
            return
        }
        
        let dataSource = MenuViewDataSourceSpy()
        dataSource.widthForItem = 50
        dataSource.registerNib(to: pagingMenuView)
        dataSource.data = Array(repeating: "foo", count: 10)
        pagingMenuView.dataSource = dataSource
        
        pagingMenuView.reloadData()
        pagingMenuView.scroll(index: 0)
        XCTAssertEqual(
            pagingMenuView.visibleCells.filter({ $0.isSelected }).first?.index,
            0,
            "updated isSelected on index 0")
        
        pagingMenuView.scroll(index: 5)
        XCTAssertEqual(
            pagingMenuView.visibleCells.filter({ $0.isSelected }).first?.index,
            5,
            "updated isSelected on index 5")
        
        pagingMenuView.scroll(index: 3, percent: 0.4)
        XCTAssertEqual(
            pagingMenuView.visibleCells.filter({ $0.isSelected }).first?.index,
            3,
            "updated isSelected on index 3")
        
        pagingMenuView.scroll(index: 3, percent: 0.6)
        XCTAssertEqual(
            pagingMenuView.visibleCells.filter({ $0.isSelected }).first?.index,
            4,
            "updated isSelected on index 4")
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
