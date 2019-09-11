//
//  SimpleView.swift
//  iOS Sample
//
//  Created by Kazuhiro Hayashi on 6/22/1 R.
//  Copyright © 2019 Kazuhiro Hayashi. All rights reserved.
//

import SwiftUI
import PagingKit

struct MenuElement: Identifiable {
    let title: String
    var id: String { title }
}

@available(iOS 13.0, *)
struct EmojiList: View {
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

@available(iOS 13, *)
struct SimpleView : View {
    @State var currentOffset: (index: Int, percent: Float) = (index: 0, percent: 0)
    
    var body: some View {
        VStack(spacing: 0) {
            PagingMenu(data: [
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
            
            PagingContent(controllers: [
                UIHostingController(rootView: EmojiList()),
                UIHostingController(rootView: EmojiList()),
                UIHostingController(rootView: EmojiList()),
                UIHostingController(rootView: EmojiList()),
                UIHostingController(rootView: EmojiList()),
                UIHostingController(rootView: EmojiList()),
                UIHostingController(rootView: EmojiList()),
                UIHostingController(rootView: EmojiList()),
                UIHostingController(rootView: EmojiList()),
                UIHostingController(rootView: EmojiList()),
                UIHostingController(rootView: EmojiList())
                ],
                currentOffset: $currentOffset
            )
        }.edgesIgnoringSafeArea([.bottom, .leading, .trailing])
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
