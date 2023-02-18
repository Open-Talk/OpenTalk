//
//  StartView.swift
//  OpenTalk
//
//  Created by Omar Elamri on 2/18/23.
//

import SwiftUI

enum Views: String {
    case Interview
    case OrderCoffee
}

func converter(v: Views) -> String {
    switch (v) {
    case .Interview: return "Interview"
    case .OrderCoffee: return "Ordering a Coffee"
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
                    Text("Open Talk").font(.title).bold()
                    Spacer()
                }
                
                List {
                    Text("Choose a Scenario").bold()
                    NavigationLink(converter(v: .Interview), value: Views.Interview)
                    NavigationLink(converter(v: .OrderCoffee), value: Views.OrderCoffee)
                }
                .navigationDestination(for: Views.self) { view in
                    ContentView(selection: view)
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
