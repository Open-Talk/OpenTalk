//
//  StartView.swift
//  OpenTalk
//
//  Created by Omar Elamri on 2/18/23.
//

import APIConnection
import SwiftUI

func converter(v: Views) -> String {
    switch (v) {
    case .Interview: return "Interview"
    case .OrderCoffee: return "Ordering a Coffee"
    case .Conversation: return "Free Conversation"
    case .Skins: return "Skins"
    case .Voices: return "Voices"
    }
}

extension Bundle {
  
  var icon: UIImage? {
    
    if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
       let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
       let files = primary["CFBundleIconFiles"] as? [String],
       let icon = files.last
    {
      return UIImage(named: icon)
    }
    
    return nil
  }
}

struct StartView : View {
    private let views: [Views] = [.Interview]
    @State private var path: [Views] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                HStack {
                    Spacer()
                    Image(uiImage: Bundle.main.icon ?? UIImage()).cornerRadius(10)
                    Text("OpenTalk").font(.title).bold()
                    Spacer()
                }
                
                List {
                    Section(header: Text("Choose a Scenario").bold()) {
                        NavigationLink(converter(v: .Interview), value: Views.Interview)
                        NavigationLink(converter(v: .OrderCoffee), value: Views.OrderCoffee)
                        NavigationLink(converter(v: .Conversation), value: Views.Conversation)
                    }
                    
                    Section(header: Text("View Your Items").bold()) {
                        NavigationLink(converter(v: .Skins), value: Views.Skins)
                        NavigationLink(converter(v: .Voices), value: Views.Voices)
                    }
                }
                .navigationDestination(for: Views.self) { view in
                    
                    switch view {
                    case .Interview:
                        ContentView(selection: view)
                    case .OrderCoffee:
                        ContentView(selection: view)
                    case .Conversation:
                        ContentView(selection: view)
                    case .Skins:
                        ItemsContentView(selection: view)
                    case .Voices:
                        ItemsContentView(selection: view)
                    }
                }

//                List {
//
//                }
//                .navigationDestination(for: Views.self) { view in
//                    ItemsContentView(selection: view)
//                }
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
