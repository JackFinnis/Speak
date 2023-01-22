//
//  ImagePicker.swift
//  Ecommunity
//
//  Created by Jack Finnis on 22/11/2021.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    let sourceType: UIImagePickerController.SourceType
    let completion: (UIImage) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
                parent.completion(uiImage)
                parent.dismiss()
            }
        }
    }
}

extension UIImagePickerController.SourceType: Identifiable {
    public var id: UUID { UUID() }
}
