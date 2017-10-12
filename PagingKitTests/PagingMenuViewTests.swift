//
//  PagingMenuViewTests.swift
//  PagingKitTests
//
//  Created by kahayash on 2017/10/12.
//  Copyright © 2017年 Kazuhiro Hayashi. All rights reserved.
//

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
    
    func testInvalidateLayout() {
        let dataSource = MenuViewDataSourceSpy()
        dataSource.widthForItem = 100
        dataSource.registerNib(to: pagingMenuView)
        dataSource.data = Array(repeating: "foo", count: 20)
        pagingMenuView?.dataSource = dataSource
        pagingMenuView?.reloadData()
        
        dataSource.widthForItem = 20
        pagingMenuView?.invalidateLayout()
        
        XCTAssertEqual(pagingMenuView?.contentSize.width, 400, "success to change content layout")
        
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
