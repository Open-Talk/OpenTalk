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
    @State var dictations: [String] = []
    
    @StateObject var sr = SpeechRecognizer()
    
    var body: some View {
//        ARViewContainer().edgesIgnoringSafeArea(.all)
        
        VStack {
            Text(title).font(.title).bold()
            
            List {
                ForEach(dictations, id: \.self) {
                    Text($0)
                }
            }
            
            HStack {
                Spacer()
                Button("Start") {
                    title = "Starting"
                    
                    sr.reset()
                    sr.transcribe()
                    sr.addHandle {
                        print("main")
                        dictations.append($0)
                    }
                    
                }.buttonStyle(.bordered)
                Spacer()
                Button("Stop") {
                    title = "Open Talk"
                    sr.stopTranscribing()
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
