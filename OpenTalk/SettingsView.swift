//
//  SettingsView.swift
//  OpenTalk
//
//  Created by Arya Gharib on 2/19/23.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.isPresented) var isPresented
    @State private var isToggled = UserDefaults.standard.bool(forKey: "ARCaptions")
    
    var body: some View {
        List {
            Toggle("Display AR Mode Captions", isOn: $isToggled)
                .onChange(of: isToggled) { value in
                    UserDefaults.standard.set(value, forKey: "ARCaptions")
                }
        }
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}
