//
//  ContentAppearanceHandlerTests.swift
//  PagingKitTests
//
//  Created by kahayash on 2019/12/19.
//  Copyright © 2019 Kazuhiro Hayashi. All rights reserved.
//

import XCTest
@testable import PagingKit

class ContentAppearanceHandlerTests: XCTestCase {
    var subject: ContentsAppearanceHandler!
    
    override func setUp() {
        subject = ContentsAppearanceHandler()
    }

    override func tearDown() {
        subject = nil
    }

    func test_viewDidDissapear_beginDragging() {
            let vcs: [UIViewControllerAppearanceSpy] = [UIViewControllerAppearanceSpy(), UIViewControllerAppearanceSpy(), UIViewControllerAppearanceSpy()]
            
            subject.beginDragging(at: 1)
            
            XCTAssertEqual(vcs[0].viewDidDisappear_wasCalled, false)
            XCTAssertEqual(vcs[1].viewDidDisappear_wasCalled, false)
            XCTAssertEqual(vcs[2].viewDidDisappear_wasCalled, false)
            
            subject.contentsDequeueHandler = {
                vcs
            }
            
            subject.beginDragging(at: 1)
            
            XCTAssertEqual(vcs[0].viewWillDisappear_wasCalled, false)
            XCTAssertEqual(vcs[1].viewWillDisappear_wasCalled, true)
            XCTAssertEqual(vcs[2].viewWillDisappear_wasCalled, false)
            
            subject.beginDragging(at: 2)
            
            XCTAssertEqual(vcs[1].viewDidDisappear_wasCalled, true)
            XCTAssertEqual(vcs[2].viewWillDisappear_wasCalled, true)

    }
    
    func test_viewWiiAppear_viewDidDissapear_viewDidAppear_stopScrolling() {
        let vcs: [UIViewControllerAppearanceSpy] = [UIViewControllerAppearanceSpy(), UIViewControllerAppearanceSpy(), UIViewControllerAppearanceSpy()]
        
        subject.contentsDequeueHandler = {
            vcs
        }
        
        subject.beginDragging(at: 1)
        
        XCTAssertEqual(vcs[1].viewWillDisappear_wasCalled, true)
        
        subject.stopScrolling(at: 2)
        
        XCTAssertEqual(vcs[1].viewDidDisappear_wasCalled, true)
        XCTAssertEqual(vcs[2].viewWillAppear_wasCalled, true)
        XCTAssertEqual(vcs[2].viewDidAppear_wasCalled, true)
    }
    
    func test_callApparance() {
            let vcs: [UIViewControllerAppearanceSpy] = [UIViewControllerAppearanceSpy(), UIViewControllerAppearanceSpy(), UIViewControllerAppearanceSpy()]
            
            subject.contentsDequeueHandler = {
                vcs
            }
            
            XCTAssertEqual(vcs[1].viewWillAppear_wasCalled, false)
            XCTAssertEqual(vcs[1].viewDidAppear_wasCalled, false)
            XCTAssertEqual(vcs[1].viewWillDisappear_wasCalled, false)
            XCTAssertEqual(vcs[1].viewDidDisappear_wasCalled, false)
            
            subject.callApparance(.viewWillAppear, animated: false, at: 1)
            
            XCTAssertEqual(vcs[1].viewWillAppear_wasCalled, true)
            XCTAssertEqual(vcs[1].viewDidAppear_wasCalled, false)
            XCTAssertEqual(vcs[1].viewWillDisappear_wasCalled, false)
            XCTAssertEqual(vcs[1].viewDidDisappear_wasCalled, false)
            
            subject.callApparance(.viewDidAppear, animated: false, at: 1)
            
            XCTAssertEqual(vcs[1].viewWillAppear_wasCalled, true)
            XCTAssertEqual(vcs[1].viewDidAppear_wasCalled, true)
            XCTAssertEqual(vcs[1].viewWillDisappear_wasCalled, false)
            XCTAssertEqual(vcs[1].viewDidDisappear_wasCalled, false)
            
            subject.callApparance(.viewWillDisappear, animated: false, at: 1)
            
            XCTAssertEqual(vcs[1].viewWillAppear_wasCalled, true)
            XCTAssertEqual(vcs[1].viewDidAppear_wasCalled, true)
            XCTAssertEqual(vcs[1].viewWillDisappear_wasCalled, true)
            XCTAssertEqual(vcs[1].viewDidDisappear_wasCalled, false)
            
            subject.callApparance(.viewDidDisappear, animated: false, at: 1)
            
            XCTAssertEqual(vcs[1].viewWillAppear_wasCalled, true)
            XCTAssertEqual(vcs[1].viewDidAppear_wasCalled, true)
            XCTAssertEqual(vcs[1].viewWillDisappear_wasCalled, true)
            XCTAssertEqual(vcs[1].viewDidDisappear_wasCalled, true)
    }
    
    func test_callApparance_WhileScrolling() {
            let vcs: [UIViewControllerAppearanceSpy] = [UIViewControllerAppearanceSpy(), UIViewControllerAppearanceSpy(), UIViewControllerAppearanceSpy()]
            
            subject.contentsDequeueHandler = {
                vcs
            }
        
            subject.beginDragging(at: 1)
            
            XCTAssertEqual(vcs[1].viewWillDisappear_wasCalled, true)
            XCTAssertEqual(vcs[1].viewDidDisappear_wasCalled, false)
        
            subject.callApparance(.viewWillAppear, animated: false, at: 1)
            
            XCTAssertEqual(vcs[1].viewWillDisappear_wasCalled, true)
            XCTAssertEqual(vcs[1].viewDidDisappear_wasCalled, true)
    }
    
    func test_preReload() {
            let vcs: [UIViewControllerAppearanceSpy] = [UIViewControllerAppearanceSpy(), UIViewControllerAppearanceSpy(), UIViewControllerAppearanceSpy()]
            
            subject.contentsDequeueHandler = {
                vcs
            }
        
            subject.preReload(at: 1)
            
            XCTAssertEqual(vcs[1].viewWillDisappear_wasCalled, true)
            XCTAssertEqual(vcs[1].viewDidDisappear_wasCalled, true)
    }
    
    func test_postReload() {
                let vcs: [UIViewControllerAppearanceSpy] = [UIViewControllerAppearanceSpy(), UIViewControllerAppearanceSpy(), UIViewControllerAppearanceSpy()]
                
                subject.contentsDequeueHandler = {
                    vcs
                }
            
                subject.postReload(at: 1)
                
                XCTAssertEqual(vcs[1].viewWillAppear_wasCalled, true)
                XCTAssertEqual(vcs[1].viewDidAppear_wasCalled, true)
    }
}


class UIViewControllerAppearanceSpy: UIViewController {
    var viewWillAppear_wasCalled = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppear_wasCalled = true
    }
    
    var viewDidAppear_wasCalled = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppear_wasCalled = true
    }
    
    var viewWillDisappear_wasCalled = false
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewWillDisappear_wasCalled = true
    }
    
    var viewDidDisappear_wasCalled = false
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewDidDisappear_wasCalled = true
    }
}
