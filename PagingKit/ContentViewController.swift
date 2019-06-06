//
//  ContentViewController.swift
//  PagingKit
//
//  Created by Kazuhiro Hayashi on 6/4/31 H.
//  Copyright © 2019 Kazuhiro Hayashi. All rights reserved.
//

import SwiftUI
import UIKit

struct ContentViewController: UIViewControllerRepresentable {
    func makeCoordinator() -> ContentViewController.Coordinator {
        Coordinator(self)
    }
    
    var controllers: [UIViewController]
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ContentViewController>) -> PagingContentViewController {
        return PagingContentViewController()
    }
    
    func updateUIViewController(_ uiViewController: PagingContentViewController, context: UIViewControllerRepresentableContext<ContentViewController>) {
        uiViewController.reloadData()
    }
    
    class Coordinator: NSObject, PagingContentViewControllerDataSource {
        func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
            return parent.controllers.count
        }
        
        func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
            parent.controllers[index]
        }
        
        var parent: ContentViewController
        
        init(_ contentViewController: ContentViewController) {
            self.parent = contentViewController
        }
    }
}
