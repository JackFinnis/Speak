//
//  TextView.swift
//  Text
//
//  Created by Jack Finnis on 12/02/2023.
//

import SwiftUI

struct TextView: UIViewRepresentable {
    @EnvironmentObject var speakVM: SpeakVM
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = speakVM
        speakVM.textView = textView
        
        textView.text = speakVM.text
        
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        textView.textContainer.lineFragmentPadding = 0
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.isSelectable = true
        
        let toolbar = UIToolbar()
        let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: speakVM, action: #selector(SpeakVM.clearText))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let dismissButton = UIBarButtonItem(title: "Done", style: .done, target: speakVM, action: #selector(SpeakVM.stopEditing))
        toolbar.items = [clearButton, spacer, dismissButton]
        toolbar.sizeToFit()
        textView.inputAccessoryView = toolbar
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        textView.font = .systemFont(ofSize: UIFont.buttonFontSize)
    }
}
