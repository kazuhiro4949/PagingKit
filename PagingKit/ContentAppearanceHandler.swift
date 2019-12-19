//
//  ContentAppearanceHandler.swift
//  PagingKit
//
//  Created by kahayash on 2019/12/19.
//  Copyright © 2019 Kazuhiro Hayashi. All rights reserved.
//

import Foundation

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
            vc.beginAppearanceTransition(true, animated: true)
        case .viewWillDisappear:
            vc.beginAppearanceTransition(false, animated: true)
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
        
        vc.beginAppearanceTransition(false, animated: false)
        vc.endAppearanceTransition()
        
    }
}

