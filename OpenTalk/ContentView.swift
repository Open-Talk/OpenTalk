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
    
    let synth = AVSpeechSynthesizer()
    
    var ac = APIConnection()
    
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
                            ForEach(dictations, id: \.self) {
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
                    
                    try! AVAudioSession.sharedInstance().setCategory(.playAndRecord)
                    
                    sr.addHandle {
                        (text, isFinal) -> () in
                        synth.stopSpeaking(at: .word)
                        
                        let last = dictations.last { $0.user == "user" }
                        let idx = dictations.lastIndex { $0.user == "user" }
                        if let last = last {
                            if (!isFinal) {
                                if let idx = idx { dictations.remove(at: idx) }
                                
                                dictations.append(Dictation(time: Date(), text: Array(text.suffix(from: last.marker)).joined(separator: " "), marker: last.marker, user: "user"))
                            } else {
                                dictations.append(Dictation(time: Date(), text: "", marker: text.count, user: "user"))
                                
                                Task.init {
                                    print(last.text)
                                    if last.text == "" { return }
                                    let text = try await ac.getResponse(prompt: last.text)
                                    speak(text: text)
                                    dictations.append(
                                        Dictation(
                                            time: Date(),
                                            text: text,
                                            marker: 0,
                                            user: "remote" )
                                    )
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
                    synth.stopSpeaking(at: .word)
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
            speak(text: "Test google test google test google")
        }
    }
    
    func speak(text: String) {
        // Create an utterance.
        let utterance = AVSpeechUtterance(string: text)

        // Configure the utterance.
        utterance.rate = 0.57
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.8

//        // Retrieve the American English voice.
//        let voice = AVSpeechSynthesisVoice()
//
//        // Assign the voice to the utterance.
//        utterance.voice = voice

        // Tell the synthesizer to speak the utterance.
        self.synth.speak(utterance)
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
