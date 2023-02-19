//
//  SpeechRecognizer.swift
//  OpenTalk
//
//  Created by Omar Elamri on 2/17/23.
//

import AVFoundation
import Foundation
import Speech
import SwiftUI

typealias Handler = ([String], Bool) -> ()

class SpeechRecognizer: ObservableObject {
    enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable
        
        var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer"
            case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            }
        }
    }
    
    var transcript: String = ""
    
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?
    
    private var handler: Handler?
    private var lastTranscription = Date()
    
    init(handle: Handler? = nil) {
        recognizer = SFSpeechRecognizer()
        handler = handle
        Task(priority: .background) {
            do {
                guard recognizer != nil else {
                    throw RecognizerError.nilRecognizer
                }
                guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                    throw RecognizerError.notAuthorizedToRecognize
                }
                guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                    throw RecognizerError.notPermittedToRecord
                }
            } catch {
                speakError(error)
            }
        }
    }
    
    deinit {
        reset()
    }
    
    func transcribe() {
        if let recognitionTask = self.task {
            recognitionTask.cancel()
            self.task = nil
        }

        guard let recognizer = self.recognizer, recognizer.isAvailable else {
            self.speakError(RecognizerError.recognizerIsUnavailable)
            return
        }
        
        do {
            let (audioEngine, request) = try prepareEngine()
            self.audioEngine = audioEngine
            self.request = request
            self.task = recognizer.recognitionTask(with: request, resultHandler: self.recognitionHandler(result:error:))
        } catch {
            self.reset()
            self.speakError(error)
        }
    }
    
    func addHandle(handle: @escaping Handler) {
        handler = handle
    }
    
    func stopTranscribing() {
        reset()
    }
    
    func resetTranscription() {
        reset()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.transcribe()
        }
    }
    
    func reset() {
        task?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        task = nil
    }
    
    private func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()
        
        self.request = SFSpeechAudioBufferRecognitionRequest()
        self.request!.shouldReportPartialResults = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 512, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.request!.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        return (audioEngine, self.request!)
    }
    
    private func recognitionHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        let receivedFinalResult = result?.isFinal ?? false
        let receivedError = error != nil
        
        self.lastTranscription = Date()
        
        if receivedFinalResult || receivedError {
            audioEngine?.stop()
            audioEngine?.inputNode.removeTap(onBus: 0)
        }

        if let result = result, let handler = handler, !receivedError, task != nil {
            handler(result.bestTranscription.segments.map { $0.substring }, result.isFinal)
        }
        
        if let result = result {
            speak(result.bestTranscription.formattedString)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if (Date() - self.lastTranscription) > 2 {
                if self.task != nil {
                    self.handler?(result?.bestTranscription.segments.map { $0.substring } ?? [], true)
                }
            }
        }
    }
    
    private func speak(_ message: String) {
        transcript = message
    }
    
    private func speakError(_ error: Error) {
        var errorMessage = ""
        if let error = error as? RecognizerError {
            errorMessage += error.message
        } else {
            errorMessage += error.localizedDescription
        }
        transcript = "<< \(errorMessage) >>"
    }
}

extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}
