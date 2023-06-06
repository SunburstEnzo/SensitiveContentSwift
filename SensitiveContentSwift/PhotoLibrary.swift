//
//  PhotoLibrary.swift
//  FrameByFrame
//
//  Created by Aled Samuel on 20/05/2023.
//

import SwiftUI
import PhotosUI

struct PhotosUILibraryChooser: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    @Environment(\.presentationMode) var presentationMode

    class CoordinatorUI: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
        
        let parent: PhotosUILibraryChooser

        init(_ parent: PhotosUILibraryChooser) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true, completion: nil)
            
            guard let result = results.first else { return }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                    self?.parent.presentationMode.wrappedValue.dismiss()
                } else if let image = image as? UIImage {
                    DispatchQueue.main.async { [weak self] in
                        self?.parent.selectedImage = image
                        self?.parent.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    func makeCoordinator() -> CoordinatorUI {
        CoordinatorUI(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<PhotosUILibraryChooser>) -> PHPickerViewController {
        
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .any(of: [.images])
        
        let imagePicker = PHPickerViewController(configuration: configuration)
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<PhotosUILibraryChooser>) {
        // Update the view controller if needed
    }
}
