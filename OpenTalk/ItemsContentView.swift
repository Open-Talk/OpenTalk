//
//  ItemsContentView.swift
//  OpenTalk
//
//  Created by Arya Gharib on 2/18/23.
//

import SwiftUI
import APIConnection

struct ItemsContentView: View {
    let selection: Views
    
    let skins: [String] = ["Rabbit"]
    let voices: [String] = ["Default"]

    var body: some View {
        List {
            Section(header: Text("My " + converter(v: selection) + ":")) {
                let toDisplay = selection == Views.Skins ? skins : voices
                ForEach(toDisplay, id: \.self) { item in
                    Text(item)
                }
            }
            Section(header: Text("Get More " + converter(v: selection) + ":")) {
                Text("More " + converter(v: selection) + " coming soon!")
            }
        }
    }
}

//struct ItemsContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ItemsContentView()
//    }
//}
