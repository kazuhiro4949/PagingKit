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
    @State var currentOffset: (index: Int, percent: Float) = (index: 0, percent: 0)
    
    var body: some View {
        VStack(spacing: 0) {
            Menu(data: [
                MenuElement(title: "1"),
                MenuElement(title: "2"),
                MenuElement(title: "3"),
                MenuElement(title: "4"),
                MenuElement(title: "5"),
                MenuElement(title: "6"),
                MenuElement(title: "7"),
                MenuElement(title: "9"),
                MenuElement(title: "10"),
                MenuElement(title: "11"),
                MenuElement(title: "12")],
                 focus: Focus(),
                 currentOffset: $currentOffset) { id in
                    MenuRow(title: id.title).frame(width: 100)
                }.frame(height: 44)
            
            Content(controllers: [
                UIHostingController(rootView: SimpleList()),
                UIHostingController(rootView: SimpleList()),
                UIHostingController(rootView: SimpleList()),
                UIHostingController(rootView: SimpleList()),
                UIHostingController(rootView: SimpleList()),
                UIHostingController(rootView: SimpleList()),
                UIHostingController(rootView: SimpleList()),
                UIHostingController(rootView: SimpleList()),
                UIHostingController(rootView: SimpleList()),
                UIHostingController(rootView: SimpleList()),
                UIHostingController(rootView: SimpleList())
                ],
                currentOffset: $currentOffset
            )
        }.edgesIgnoringSafeArea([.bottom, .leading, .trailing])
    }
}

struct MenuElement: Identifiable {
    let title: String
    
    var id: String { title }
}

@available(iOS 13.0, *)
struct SimpleList: View {
    var body: some View {
        List {
            ForEach(["🐶", "🐭", "🐱", "🐹", "🐰", "🦊","🐻","🐼","🐨","🐯","🐶", "🐭", "🐱", "🐹", "🐰", "🦊","🐻","🐼","🐨","🐯"].identified(by: \.self)) { text in
                Text(text)
            }
        }
    }
}

@available(iOS 13.0, *)
struct Focus: View {
    var body: some View {
        VStack {
            Spacer()
            Rectangle().frame(height: 4).foregroundColor(.red)
        }
    }
}

@available(iOS 13.0, *)
struct MenuRow: View {
    let title: String
    
    var body: some View {
        Text(title)
    }
}

//#if DEBUG
//@available(iOS 13, *)
//struct SimpleView_Previews : PreviewProvider {
//    static var previews: some View {
//        SimpleView()
//    }
//}
//#endif


@available(iOS 13.0, *)
struct Menu<Data, Content, Focus>: UIViewControllerRepresentable where Data : RandomAccessCollection, Content: View, Focus: View, Data.Element : Identifiable, Data.Index == Int {
    var data: Data
    var focus: Focus
    @Binding var currentOffset: (index: Int, percent: Float)
    var content: (Data.Element.IdentifiedValue) -> Content
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<Menu>) -> PagingMenuViewController {
        let vc = PagingMenuViewController()
        vc.register(type: PagingMenuViewCell.self, forCellWithReuseIdentifier: "identifier")
        vc.dataSource = context.coordinator
        vc.delegate = context.coordinator
        let focusVc = UIHostingController(rootView: focus)
        focusVc.view.backgroundColor = .clear
        vc.registerFocusView(view: focusVc.view)
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: PagingMenuViewController, context: UIViewControllerRepresentableContext<Menu>) {
        
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

        var parent: Menu

        init(_ vc: Menu) {
            parent = vc
        }
    }
}

@available(iOS 13.0, *)
struct Content: UIViewControllerRepresentable {
    var controllers: [UIViewController]
    @Binding var currentOffset: (index: Int, percent: Float)
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<Content>) -> PagingContentViewController {
        let vc = PagingContentViewController()
        vc.dataSource = context.coordinator
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: PagingContentViewController, context: UIViewControllerRepresentableContext<Content>) {
        if !context.coordinator.isReloaded {
            uiViewController.reloadData()
            context.coordinator.isReloaded.toggle()
        } else if !context.coordinator.isManualScrolling {
            uiViewController.scroll(to: currentOffset.index, animated: true)
        }
    }
    
    class Coordinator: PagingContentViewControllerDelegate, PagingContentViewControllerDataSource {
        var parent: Content
        var isReloaded = false
        var isManualScrolling = false
        
        init(_ vc: Content) {
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
