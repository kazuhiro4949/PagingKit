//
//  SimpleView.swift
//  iOS Sample
//
//  Created by kahayash on 6/22/1 R.
//  Copyright © 2019 Kazuhiro Hayashi. All rights reserved.
//

import SwiftUI

@available(iOS 13, *)
struct SimpleView : View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello World!"/*@END_MENU_TOKEN@*/)
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
