//
//  PagingContentViewControllerTests.swift
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
