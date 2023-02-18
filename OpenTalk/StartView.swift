//
//  StartView.swift
//  OpenTalk
//
//  Created by Omar Elamri on 2/18/23.
//

import SwiftUI

let views = ["Interview"]

struct StartView : View {
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Text("Open Talk").font(.title).bold()
                    Spacer()
                }
                
                List {
//                    ForEach(views, id: \.self) {
//
//                    }
                }
            }
        }
    }
}

#if DEBUG
struct StartView_Previews : PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
#endif
