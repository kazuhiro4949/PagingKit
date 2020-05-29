//
//  ContentAppearanceHandler.swift
//  PagingKit
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

import UIKit

protocol ContentsAppearanceHandlerProtocol {
    var contentsDequeueHandler: (() -> [UIViewController?]?)? { get set }
    func beginDragging(at index: Int)
    func stopScrolling(at index: Int)
    func callApparance(_ apperance: ContentsAppearanceHandler.Apperance, animated: Bool, at index: Int)
    func preReload(at index: Int)
    func postReload(at index: Int)
}

class ContentsAppearanceHandler: ContentsAppearanceHandlerProtocol {
    enum Apperance {
        case viewDidAppear
        case viewWillAppear
        case viewDidDisappear
        case viewWillDisappear
    }
    
    private var dissapearingIndex: Int?
    var contentsDequeueHandler: (() -> [UIViewController?]?)?
    

    func beginDragging(at index: Int) {
        guard let vcs = contentsDequeueHandler?(), index < vcs.endIndex, let vc = vcs[index] else {
            return
        }
        
        if let dissapearingIndex = dissapearingIndex, dissapearingIndex < vcs.endIndex, let prevVc = vcs[dissapearingIndex] {
            prevVc.endAppearanceTransition()
        }
        
        vc.beginAppearanceTransition(false, animated: false)
        dissapearingIndex = index
    }
    
    func stopScrolling(at index: Int) {
        guard let vcs = contentsDequeueHandler?(), index < vcs.endIndex, let vc = vcs[index] else {
            return
        }
        
        if let dissapearingIndex = dissapearingIndex, dissapearingIndex < vcs.endIndex, let prevVc = vcs[dissapearingIndex] {
            prevVc.endAppearanceTransition()
        }
        
        vc.beginAppearanceTransition(true, animated: false)
        vc.endAppearanceTransition()
        dissapearingIndex = nil
    }
    
    func callApparance(_ apperance: Apperance, animated: Bool, at index: Int) {
        guard let vcs = contentsDequeueHandler?(), index < vcs.endIndex, let vc = vcs[index] else {
            return
        }
        
        if let dissapearingIndex = dissapearingIndex,
            dissapearingIndex < vcs.endIndex,
            let prevVc = vcs[dissapearingIndex],
            dissapearingIndex == index {
            
            prevVc.endAppearanceTransition()
        }
        dissapearingIndex = nil
        
        switch apperance {
        case .viewDidAppear, .viewDidDisappear:
            vc.endAppearanceTransition()
        case .viewWillAppear:
            vc.beginAppearanceTransition(true, animated: animated)
        case .viewWillDisappear:
            vc.beginAppearanceTransition(false, animated: animated)
        }
    }
    
    func preReload(at index: Int) {
        guard let vcs = contentsDequeueHandler?(), index < vcs.endIndex, let vc = vcs[index] else {
            return
        }
        
        vc.beginAppearanceTransition(false, animated: false)
        vc.endAppearanceTransition()
        
    }
    
    
    
    func postReload(at index: Int) {
        guard let vcs = contentsDequeueHandler?(), index < vcs.endIndex, let vc = vcs[index] else {
            return
        }
        
        vc.beginAppearanceTransition(true, animated: false)
        vc.endAppearanceTransition()
        
    }
}

