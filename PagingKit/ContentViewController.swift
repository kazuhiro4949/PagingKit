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
    var controller: [UIViewController]
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ContentViewController>) -> PagingContentViewController {
        return PagingContentViewController()
    }
    
    func updateUIViewController(_ uiViewController: PagingContentViewController, context: UIViewControllerRepresentableContext<ContentViewController>) {
        
    }
}
