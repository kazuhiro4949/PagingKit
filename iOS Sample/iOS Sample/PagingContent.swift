//
//  PagingContent.swift
//  iOS Sample
//
//  Created by Kazuhiro Hayashi on 6/23/1 R.
//  Copyright © 1 Reiwa Kazuhiro Hayashi. All rights reserved.
//

import SwiftUI
import PagingKit

@available(iOS 13.0, *)
struct PagingContent: UIViewControllerRepresentable {
    var controllers: [UIViewController]
    @Binding var currentOffset: (index: Int, percent: Float)
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PagingContent>) -> PagingContentViewController {
        let vc = PagingContentViewController()
        vc.dataSource = context.coordinator
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: PagingContentViewController, context: UIViewControllerRepresentableContext<PagingContent>) {
        if !context.coordinator.isReloaded {
            uiViewController.reloadData()
            context.coordinator.isReloaded.toggle()
        } else if !context.coordinator.isManualScrolling {
            uiViewController.scroll(to: currentOffset.index, animated: true)
        }
    }
    
    class Coordinator: PagingContentViewControllerDelegate, PagingContentViewControllerDataSource {
        var parent: PagingContent
        var isReloaded = false
        var isManualScrolling = false
        
        init(_ vc: PagingContent) {
            parent = vc
        }
        
        func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
            parent.controllers[index]
        }
        
        func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
            parent.controllers.count
        }
        
        func contentViewController(viewController: PagingContentViewController, willBeginManualScrollOn index: Int) {
            isManualScrolling = true
        }
        
        func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
            parent.currentOffset = (index: index, percent: Float(percent))
        }
        
        func contentViewController(viewController: PagingContentViewController, didEndManualScrollOn index: Int) {
            isManualScrolling = false
        }
    }
}
