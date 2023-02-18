//
//  ContentView.swift
//  OpenTalk
//
//  Created by Omar Elamri on 2/17/23.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    @State var title = "Open Talk"
    @State var dictations: [String] = ["Test", "Test1"]
    @State var openAR: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text(title).font(.title).bold()
                Spacer()
                Button("Toggle AR Mode") {
                    openAR = !openAR
                }
            }
            if openAR {
                ARViewContainer().edgesIgnoringSafeArea(.all)
            } else {
                VStack {
                    List {
                        ForEach(dictations, id: \.self) {
                            Text($0)
                        }
                    }
                }
            }
            HStack {
                Spacer()
                Button("Start") {
                    title = "Listening..."
                }.buttonStyle(.bordered)
                Spacer()
                Button("Stop") {
                    title = "Press Start to Listen"
                    dictations = []
                }.buttonStyle(.bordered)
                Spacer()
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
