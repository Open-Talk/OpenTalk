//
//  ContentView.swift
//  OpenTalk
//
//  Created by Omar Elamri on 2/17/23.
//

import APIConnection
import AVFoundation
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
    @State var recording = false
    
    @StateObject var sr = SpeechRecognizer()
    @State var openAR: Bool = false
    
    @StateObject var ac = APIConnection()
    
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
                ZStack {
                    arView
                    dictations.last != nil ?
                    VStack {
                        Spacer()
                        Text((dictations.last!.user == "user" ? "User: " : "Remote: ") + dictations.last!.text)
                            .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                            .background(Color.black)
                            .cornerRadius(10)
                        Spacer().frame(height: 20)
                    } : nil
                }
            } else {
                VStack {
                    if dictations.last != nil {
                        List {
                            ForEach(dictations.reversed(), id: \.self) {
                                $0.text != "" ? Text(($0.user == "user" ? "User: " : "Remote: ") + $0.text) : nil
                            }
                        }
                    } else {
                        List {
                            Text("Tap Start to speak")
                        }
                    }
                }
            }
            HStack {
                Spacer()
                Button(action: {
                    if recording { return }
                    recording = true
                    title = "Listening..."
                    sr.reset()
                    sr.transcribe()
                    
                    sr.addHandle {
                        (text, isFinal) -> () in
                        
                        let last = dictations.last { $0.user == "user" }
                        let idx = dictations.lastIndex { $0.user == "user" }
                        if let last = last {
                            if (!isFinal) {
                                if let idx = idx { dictations.remove(at: idx) }
                                var txt = text
                                var marker = last.marker
                                if text.count > last.marker {
                                    txt = Array(text.suffix(from: last.marker))
                                    marker = 0
                                }
                                dictations.append(Dictation(time: Date(), text: txt.joined(separator: " "), marker: marker, user: "user"))
                            } else {
                                dictations.append(Dictation(time: Date(), text: "", marker: text.count, user: "user"))
                                
                                Task.init {
                                    print(last.text)
                                    if last.text == "" { return }
                                    let text = try await ac.getResponse(prompt: last.text)
                                    dictations.append(
                                        Dictation(
                                            time: Date(),
                                            text: text,
                                            marker: 0,
                                            user: "remote" )
                                    )
                                    print(text)
                                    sr.stopTranscribing()
                                    SpeechService.shared.speak(text: text, completion: {if self.recording {self.sr.transcribe()}})
                                }
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
                    if !recording { return }
                    title = converter(v: selection)
                    sr.stopTranscribing()
                    ac.reset()
                    dictations = []
                    recording = false
                }) {
                    Label("Stop", systemImage: "stop.circle")
                }.buttonStyle(.bordered).buttonStyle(.bordered)
                Spacer()
            }
        }
        .onAppear() {
            self.title = converter(v: selection)
            self.ac.change(view: selection)
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
