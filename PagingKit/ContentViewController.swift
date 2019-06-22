//
//  ContentViewController.swift
//  PagingKit
//
//  Created by Kazuhiro Hayashi on 6/4/31 H.
//  Copyright © 2019 Kazuhiro Hayashi. All rights reserved.
//

import SwiftUI
import UIKit

@available(iOS 13.0, *)
public struct Menu<Selection, Content> where Selection : SelectionManager, Content : View {
    
    /// Creates an instance.
    ///
    /// - Parameter selection: A selection manager that identifies the selected row(s).
    ///
    /// - See Also: `View.selectionValue` which gives an identifier to the rows.
    ///
    /// - Note: On iOS and tvOS, you must explicitly put the `List` into Edit
    /// Mode for the selection to apply.
    public init(selection: Binding<Selection>?, content: () -> Content) {
        
    }
    
    /// The type of view representing the body of this view.
    ///
    /// When you create a custom view, Swift infers this type from your
    /// implementation of the required `body` property.
    public typealias Body = Never
}


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
