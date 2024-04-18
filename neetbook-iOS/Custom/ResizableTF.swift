//
//  ResizableTF.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 3/31/24.
//

import SwiftUI

struct ResizableTF: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    
    func makeCoordinator() -> Coordinator {
        return ResizableTF.Coordinator(parent1: self)
    }
    
    func makeUIView(context: Context) -> some UITextView {
        let view = UITextView()
        view.isEditable = true
        view.isScrollEnabled = true
        view.text = "Enter Comment"
        view.textColor = .gray
        view.backgroundColor = .white
        view.delegate = context.coordinator
        view.font = UIFont.systemFont(ofSize: 16)
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            self.height = uiView.contentSize.height < 30.0 ? 30.0 : uiView.contentSize.height
        }
    }
    
    class Coordinator : NSObject, UITextViewDelegate {
        var parent: ResizableTF
        
        init(parent1: ResizableTF) {
            self.parent = parent1
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            textView.text = ""
            textView.textColor = .black
        }
        
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.height = textView.contentSize.height
                self.parent.text = textView.text
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if self.parent.text == "" {
                textView.text = "Enter Comment"
                textView.textColor = .gray
                textView.textColor = .black
            }
        }
    }
}
