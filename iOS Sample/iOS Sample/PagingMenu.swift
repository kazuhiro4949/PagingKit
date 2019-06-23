//
//  PagingMenu.swift
//  iOS Sample
//
//  Created by Kazuhiro Hayashi on 6/23/1 R.
//  Copyright © 1 Reiwa Kazuhiro Hayashi. All rights reserved.
//

import SwiftUI
import PagingKit

@available(iOS 13.0, *)
struct PagingMenu<Data, Content, Focus>: UIViewControllerRepresentable where Data : RandomAccessCollection, Content: View, Focus: View, Data.Element : Identifiable, Data.Index == Int {
    var data: Data
    var focus: Focus
    @Binding var currentOffset: (index: Int, percent: Float)
    var content: (Data.Element.IdentifiedValue) -> Content
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PagingMenu>) -> PagingMenuViewController {
        let vc = PagingMenuViewController()
        vc.register(type: PagingMenuViewCell.self, forCellWithReuseIdentifier: "identifier")
        vc.dataSource = context.coordinator
        vc.delegate = context.coordinator
        let focusVc = UIHostingController(rootView: focus)
        focusVc.view.backgroundColor = .clear
        vc.registerFocusView(view: focusVc.view)
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: PagingMenuViewController, context: UIViewControllerRepresentableContext<PagingMenu>) {
        
        if !context.coordinator.isReloaded {
            uiViewController.reloadData(with: currentOffset.index, completionHandler: nil)
            context.coordinator.isReloaded.toggle()
        } else if !context.coordinator.isSelected {
            print(currentOffset)
            uiViewController.scroll(index: currentOffset.index, percent: CGFloat(currentOffset.percent), animated: false)
        }
        context.coordinator.isSelected = false
    }
    
    class Coordinator: PagingMenuViewControllerDelegate, PagingMenuViewControllerDataSource {
        let sizingCell = PagingMenuViewCell(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        var isReloaded = false
        var isSelected = false
        
        func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
            let element = parent.data[index]
            let content = parent.content(element.identifiedValue)
            let controller = UIHostingController(rootView: content)
            
            sizingCell.subviews.forEach { $0.removeFromSuperview() }
            sizingCell.addSubview(controller.view)
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            controller.view.topAnchor.constraint(equalTo: sizingCell.topAnchor).isActive = true
            controller.view.bottomAnchor.constraint(equalTo: sizingCell.bottomAnchor).isActive = true
            controller.view.leadingAnchor.constraint(equalTo: sizingCell.leadingAnchor).isActive = true
            controller.view.trailingAnchor.constraint(equalTo: sizingCell.trailingAnchor).isActive = true
            let size = sizingCell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            return size.width
        }
        
        func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
            let element = parent.data[index]
            let content = parent.content(element.identifiedValue)
            let controller = UIHostingController(rootView: content)
            
            let cell = viewController.dequeueReusableCell(withReuseIdentifier: "identifier", for: index)
            cell.subviews.forEach { $0.removeFromSuperview() }
            cell.addSubview(controller.view)
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            controller.view.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
            controller.view.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
            controller.view.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive = true
            controller.view.trailingAnchor.constraint(equalTo: cell.trailingAnchor).isActive = true
            return cell
        }
        
        func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
            isSelected = true
            parent.currentOffset = (index: page, percent: 0)
        }
        
        func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
            parent.data.count
        }
        
        var parent: PagingMenu
        
        init(_ vc: PagingMenu) {
            parent = vc
        }
    }
}
