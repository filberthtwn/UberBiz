//
//  AddProductDescriptionViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 01/02/21.
//

import UIKit
import UITextView_Placeholder

struct ProductDescSourceVC{
    static let EDIT = "EDIT"
    static let CREATE = "CREATE"
}

class ProductDescriptionViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var listingDescTV: UITextView!
    @IBOutlet var listingDescTVBottomC: NSLayoutConstraint!
    @IBOutlet var listingTVHeightC: NSLayoutConstraint!
    
    var productFormDelegate: AddProductDelegate?
    var sourceVC = ProductDescSourceVC.CREATE
    var desc:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupDefaultValue()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.listingDescTV.becomeFirstResponder()
    }
    
    private func setupDefaultValue(){
        if let desc = desc{
            self.listingDescTV.text = desc
        }
        
        if self.sourceVC == ProductDescSourceVC.CREATE{
            //MARK: Handle create source VC
            self.setupNavigationBar()
        }else{
            //MARK: Handle update source VC
            self.listingDescTV.isEditable = false
            self.title = "Product Description"
        }
    }
    
    private func setupNavigationBar(){
        let barButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction(_:)))
        barButtonItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemBlue], for: .normal)
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private func setupViews(){
        self.title = "Add Description"
        self.listingDescTV.text = ""
        
        self.listingDescTV.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.listingDescTVBottomC.constant = keyboardSize.height - 35
//            self.listingDescTV.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: keyboardSize.height, right: 16)
            }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.25) {
            self.listingDescTVBottomC.constant = 0
//            self.listingDescTV.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
            self.listingDescTV.layoutIfNeeded()
        }
        
    }
    
    @objc private func doneAction(_ sender: Any){
        productFormDelegate?.didChangeDesc(desc: listingDescTV.text)
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ProductDescriptionViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
//        print("HEIGHT: \(scrollView.contentSize.height)")
//        DispatchQueue.main.async {
//            let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
//            self.scrollView.setContentOffset(bottomOffset, animated: true)
//            self.scrollView.layoutIfNeeded()
//        }
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
//        self.view.layoutIfNeeded()
//        self.listingDescTV.layoutIfNeeded()
//        if self.listingTVHeightC.constant < self.view.frame.height{
//            DispatchQueue.main.async {
//                self.listingTVHeightC.constant = textView.contentSize.height
//                self.view.layoutIfNeeded()
//            }
//        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
//        if self.textvi
//        self.listingTVHeightC.constant = textView.contentSize.height
    }
}
