//
//  PagingContentViewControllerTests.swift
//  PagingKitTests
//
//  Created by kahayash on 2017/10/12.
//  Copyright © 2017年 Kazuhiro Hayashi. All rights reserved.
//

import XCTest
@testable import PagingKit

class PagingContentViewControllerTests: XCTestCase {
    var pagingContentViewController: PagingContentViewController?
    var dataSource: PagingContentViewControllerDataSource?
    
    override func setUp() {
        super.setUp()
        pagingContentViewController = PagingContentViewController()
        pagingContentViewController?.view.frame = CGRect(x: 0, y: 0, width: 320, height: 667)
    }
    
    override func tearDown() {
        super.tearDown()
        dataSource = nil
    }
    
    func testCallingDataSource() {
        let dataSource = PagingContentVcDataSourceMock()
        pagingContentViewController?.dataSource = dataSource
        pagingContentViewController?.reloadData()
        wait(for: [dataSource.numberOfItemExpectation, dataSource.viewControllerExpectation], timeout: 1)
        self.dataSource = dataSource
    }
}

class PagingContentVcDataSourceMock: NSObject, PagingContentViewControllerDataSource {
    let numberOfItemExpectation = XCTestExpectation(description: "call numberOfItemForContentViewController")
    let viewControllerExpectation = XCTestExpectation(description: "call viewController")
    
    func numberOfItemForContentViewController(viewController: PagingContentViewController) -> Int {
        numberOfItemExpectation.fulfill()
        return 2
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        viewControllerExpectation.fulfill()
        return UIViewController()
    }
}

class PagingContentVcDataSourceSpy: NSObject, PagingContentViewControllerDataSource {
    func numberOfItemForContentViewController(viewController: PagingContentViewController) -> Int {
        return 5
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return UIViewController()
    }
}
