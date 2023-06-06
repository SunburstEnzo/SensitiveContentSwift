//
//  ContentView.swift
//  SensitiveContentSwift
//
//  Created by Aled Samuel on 06/06/2023.
//

import SwiftUI
import PhotosUI
import SensitiveContentAnalysis

struct ContentView: View {
    
    enum Sensitivity: Equatable {
        case loading
        case warning
        case finished(sensitive: Bool)
    }
    
    @State private var sensitivity = Sensitivity.finished(sensitive: false)
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    
    private let analyzer = SCSensitivityAnalyzer()
    
    var body: some View {
        VStack {
            Spacer(minLength: 52)
            Text(textForSensitivity())
            Spacer(minLength: 16)
            if let selectedImage {
                if sensitivity == .finished(sensitive: false) {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                } else {
                    GeometryReader { geometry in
                        ZStack {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                            Text("This may be sensitive.")
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .background(.regularMaterial)
                        }
                    }
                }
            } else {
                Image(systemName: "photo.fill")
                    .imageScale(.large)
                    .foregroundStyle(.gray)
            }
            Spacer(minLength: 16)
            Button(action: {
                showImagePicker = true
            }, label: {
                Label("Choose Image", systemImage: "photo.on.rectangle")
            })
            Spacer(minLength: 32)
        }
        .padding()
        .sheet(isPresented: $showImagePicker) {
            PhotosUILibraryChooser(selectedImage: self.$selectedImage)
        }
        .onChange(of: selectedImage, {
            if let selectedImage {
                Task {
                    await isImageSensitive(image: selectedImage)
                }
            }
        })
    }
    
    func isImageSensitive(image: UIImage) async {
        
        sensitivity = .loading
        
        if analyzer.analysisPolicy == .disabled {
            print("analysisPolicy == .disabled")
            sensitivity = .warning
            return
        }
        
        guard let cgImage = image.cgImage else {
            sensitivity = .warning
            return
        }
        
        do {
            let response = try await analyzer.analyzeImage(cgImage)
            sensitivity = .finished(sensitive: response.isSensitive)
            print(response.isSensitive)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func textForSensitivity() -> String {
        
        if selectedImage == nil {
            return "No Image Selected"
        }
        
        switch sensitivity {
        case .loading:
            return "Loading…"
        case .warning:
            return "Error"
        case .finished(let sensitive):
            return sensitive ? "Is Sensitive" : "Is Not Sensitive"
        }
    }
}

#Preview {
    ContentView()
}
