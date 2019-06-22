//
//  SimpleView.swift
//  iOS Sample
//
//  Created by kahayash on 6/22/1 R.
//  Copyright © 2019 Kazuhiro Hayashi. All rights reserved.
//

import SwiftUI
import PagingKit

@available(iOS 13, *)
struct SimpleView : View {
    var body: some View {
        MenuView()
    }
}

#if DEBUG
@available(iOS 13, *)
struct SimpleView_Previews : PreviewProvider {
    static var previews: some View {
        SimpleView()
    }
}
#endif


struct MenuView: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<MenuView>) -> PagingMenuViewController {
        return PagingMenuViewController()
    }
    
    func updateUIViewController(_ uiViewController: PagingMenuViewController, context: UIViewControllerRepresentableContext<MenuView>) {
        uiViewController.reloadData()
    }
}
