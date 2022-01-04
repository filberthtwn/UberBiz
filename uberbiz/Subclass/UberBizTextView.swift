//
//  UberBizTextView.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/02/21.
//

import Foundation
import UIKit

class UberBizTextView: UITextView, UITextViewDelegate {
        
//    var placeholder:String = "Placeholder"
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
//    override init(frame: CGRect, textContainer: NSTextContainer?) {
//        super.init(frame: frame, textContainer: textContainer)
//
//        self.delegate = self
//    }
    
//    override var canBecomeFirstResponder: Bool{
//        return false
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.text != nil{
            self.textColor = UIColor.black
        }else{
            self.text = self.placeholder
            self.textColor = Color.PLACEHOLDER_COLOR
            let beginningOfSelection = self.beginningOfDocument
                    let endOfSelection = self.position(from: self.endOfDocument, offset: 4) ?? beginningOfSelection
            self.selectedTextRange = self.textRange(from: beginningOfSelection, to: endOfSelection)!
        }
        
        self.delegate = self
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.textColor == Color.PLACEHOLDER_COLOR{
            let beginningOfSelection = textView.beginningOfDocument
            let endOfSelection = textView.position(from: textView.endOfDocument, offset: 4) ?? beginningOfSelection
            DispatchQueue.main.async {
                textView.selectedTextRange = textView.textRange(from: beginningOfSelection, to: endOfSelection)!
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let currentText:String = textView.text
            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
            if updatedText.isEmpty {

                textView.text = self.placeholder
                textView.textColor = Color.PLACEHOLDER_COLOR

                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
                
            }else if textView.textColor == Color.PLACEHOLDER_COLOR && !text.isEmpty {
                textView.textColor = UIColor.black
                textView.text = text
            }else {
                return true
            }
        
            return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.textColor == Color.PLACEHOLDER_COLOR {
            DispatchQueue.main.async {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = self.placeholder
            textView.textColor = Color.PLACEHOLDER_COLOR
        }
    }
}
