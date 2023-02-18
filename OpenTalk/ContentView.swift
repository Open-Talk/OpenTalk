//
//  ContentView.swift
//  OpenTalk
//
//  Created by Omar Elamri on 2/17/23.
//

import SwiftUI
import RealityKit

extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}

struct ContentView : View {
    struct Dictation: Hashable {
        let time: Date
        let text: String
        let marker: Int
        let user: String
    }
    
    let selection: Views
    
    @State var title = ""
    @State var dictations: [Dictation] = []
    
    @StateObject var sr = SpeechRecognizer()
    @State var openAR: Bool = false
    
    var arView: some View = ARViewContainer().edgesIgnoringSafeArea(.all)
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(title).font(.title).bold()
                Spacer()
                Button(action: {
                    openAR = !openAR
                }) {
                    Label("AR Mode", systemImage: "sparkles.tv.fill")
                }
                Spacer()
            }
            if openAR {
                arView
            } else {
                VStack {
                    List {
                        ForEach(dictations, id: \.self) {
                            Text(($0.user == "user" ? "User: " : "Remote: ") + $0.text)
                        }
                    }
                }
            }
            HStack {
                Spacer()
                Button(action: {
                    title = "Listening..."
                    sr.reset()
                    sr.transcribe()
                    sr.addHandle {
                        (text, isFinal) -> () in
                        let last = dictations.last { $0.user == "user" }
                        let idx = dictations.lastIndex { $0.user == "user" }
                        if let last = last {
                            if (!isFinal) {
                                print(text)
                                print(last.marker)
                                if let idx = idx { dictations.remove(at: idx) }
                                
                                dictations.append(Dictation(time: Date(), text: Array(text.suffix(from: last.marker)).joined(separator: " "), marker: last.marker, user: "user"))
                            } else {
                                dictations.append(Dictation(time: Date(), text: "", marker: text.count, user: "user"))
                            }
                        } else {
                            dictations.append(Dictation(time: Date(), text: String(text.joined(separator: " ")), marker: 0, user: "user"))
                        }
                    }
                }) {
                    Label("Start", systemImage: "play.circle")
                }.buttonStyle(.bordered)
                Spacer()
                Button(role: .destructive, action: {
                    title = converter(v: selection)
                    sr.stopTranscribing()
                    dictations = []
                }) {
                    Label("Stop", systemImage: "stop.circle")
                }.buttonStyle(.bordered).buttonStyle(.bordered)
                Spacer()
            }
        }
        .onAppear() {
            self.title = converter(v: selection)
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

//#if DEBUG
//struct ContentView_Previews : PreviewProvider {
//    static var previews: some View {
//        ContentView(view: .Interview)
//    }
//}
//#endif
