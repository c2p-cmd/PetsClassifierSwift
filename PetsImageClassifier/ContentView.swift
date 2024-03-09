//
//  ContentView.swift
//  PetsImageClassifier
//
//  Created by Sharan Thakur on 09/03/24.
//

import CoreML
import PhotosUI
import SwiftUI

struct ContentView: View {
    private let model: PetsClassifier
    
    @State private var photoItem: PhotosPickerItem?
#if os(iOS)
    @State private var pickedImage: UIImage?
#elseif os(macOS)
    @State private var pickedImage: NSImage?
#endif
    @State private var isBusy = false
    
    @State private var output: [String: Double]?
    
    @State private var showAlert = false
    @State private var alert: String?
    
    init() {
        do {
            self.model = try PetsClassifier()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    var body: some View {
        Form {
            if let pickedImage {
                Section("Picked Image") {
#if os(iOS)
                    Image(uiImage: pickedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(.rect(cornerRadius: 20))
#elseif os(macOS)
                    Image(nsImage: pickedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .clipShape(.rect(cornerRadius: 20))
#endif
                    
                    Button("Remove", systemImage: "x.circle.fill", role: .destructive) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            self.output = nil
                            self.pickedImage = nil
                        }
                    }
                }
            }
            
            Section("Image Picker") {
                PhotosPicker(
                    selection: $photoItem,
                    matching: .any(of: [
                        .images,
                        .screenshots,
                        .not(.bursts),
                        .not(.livePhotos)
                    ]),
                    preferredItemEncoding: .automatic
                ) {
                    Label("Pick an image", systemImage: "photo.badge.plus")
                }
                .onChange(of: photoItem) { _, newValue in
                    guard let newValue else { return }
                    
                    Task {
                        do {
                            isBusy = true
                            
                            let imageData = try await newValue.loadTransferable(type: Data.self)
                            if let imageData, let image = ImageProvider(data: imageData) {
                                withAnimation(.easeIn(duration: 0.75)) {
                                    self.pickedImage = image
                                }
                            }
                            
                            isBusy = false
                        } catch {
                            isBusy = false
                            alert = error.localizedDescription
                            showAlert = true
                            print(error)
                        }
                    }
                }
            }
            
            if isBusy {
                ProgressView()
            }
            
            if let output {
                Section("Prediction Result") {
                    if let catPercent = output["cat"]?.formatted(.percent) {
                        Text("**Cat** confidence: \(catPercent)")
                    }
                    if let dogPercent = output["dog"]?.formatted(.percent) {
                        Text("**Dog** confidence: \(dogPercent)")
                    }
                    if let rabbitPercent = output["rabbit"]?.formatted(.percent) {
                        Text("**Rabbit** confidence: \(rabbitPercent)")
                    }
                }
            }
            
            Button("Predict", systemImage: "play.circle.fill") {
                predict()
            }
            .alert("Alert!", isPresented: $showAlert, presenting: alert) { _ in
                Button("Okay", role: .cancel) {
                    
                }
            } message: { alertMsg in
                Text(alertMsg)
            }
            .disabled((pickedImage == nil || isBusy))
        }
        .scrollBounceBehavior(.basedOnSize)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .navigationTitle("Pets Classifier")
    }
    
    func predict() {
        if isBusy {
            return
        }
        Task {
            isBusy = true
            do {
                guard let pickedImage, let buffer = pickedImage.colorPixelBuffer() else {
                    return
                }
                
                let input = PetsClassifierInput(image: buffer)
                let output = try await model.prediction(input: input)
                
                print(output.featureNames)
                print(output.target)
                print(output.targetProbability)
                
                withAnimation(.interactiveSpring) {
                    self.output = output.targetProbability
                }
                isBusy = false
            } catch {
                isBusy = false
                alert = error.localizedDescription
                showAlert = true
                print(error)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
