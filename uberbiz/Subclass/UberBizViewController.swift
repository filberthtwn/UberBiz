//
//  UberBizViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 04/01/21.
//

import UIKit

protocol UberBizImagePickerDelegate {
    func didImagePicked(image: UIImage)
}

class UberBizViewController: UIViewController {
    
    var searchTF: UITextField?
    var tabBarDelegate: TabBarDelegate?
    
    var searchQuery: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        if searchQuery != nil{
            self.showSearchBar()
            self.searchTF?.text = searchQuery
        }
//        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func showSearchBar(){
        self.searchTF = UITextField(frame: CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.frame.size.width)!, height: 35))
        self.searchTF!.layer.borderWidth = 1
        self.searchTF!.layer.borderColor = UIColor.init(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.25).cgColor
        self.searchTF!.font = UIFont.systemFont(ofSize: 14)
        self.searchTF!.backgroundColor = .white
        self.searchTF!.leftViewMode = .always
                
        let searchV = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: self.searchTF!.frame.height))
        let searchIV = UIImageView(image: UIImage(named: "search-icon"))
        searchIV.frame = CGRect(x: 12, y: ((searchV.frame.height - 17)/2), width: 17, height: 17)
        searchV.addSubview(searchIV)
        self.searchTF!.leftView = searchV
        
        self.searchTF!.rightViewMode = .always
        self.searchTF!.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 45))
        self.searchTF!.layer.cornerRadius = self.searchTF!.frame.height/2
        
        self.searchTF!.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(didTextFieldEditingDidBegin(_:))))
        self.navigationItem.titleView =  self.searchTF
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 16))
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(didBackAction(_:)))
        
        let backIV = UIImageView(image: UIImage(named: "chevron-left-icon"))
        backIV.frame = CGRect(x: 0, y: 0, width: 10, height: 16)
        view.addGestureRecognizer(backGesture)
        
        view.addSubview(backIV)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)
    }
    
    func showPickerModal(){
        let alert = UIAlertController(title: "Upload Image", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            self.presentImagePickerController(sourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
            self.presentImagePickerController(sourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func didImagePicked(image:UIImage, fileName:String){}
    
    private func presentImagePickerController(sourceType: UIImagePickerController.SourceType){
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = sourceType
        imagePickerVC.delegate = self
        imagePickerVC.modalPresentationStyle = .fullScreen
        
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().tintColor = .systemBlue
        let BarButtonItemAppearance = UIBarButtonItem.appearance()
        BarButtonItemAppearance.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        
        self.present(imagePickerVC, animated: true)
    }
    
    @objc func didTextFieldEditingDidBegin(_ sender: UITextField){
        let searchListingVC = SearchHistoryViewController()
        self.navigationController?.pushViewController(searchListingVC, animated: false)
    }
    
    @objc func didBackAction(_ sender: UITapGestureRecognizer){
        self.navigationController?.popViewController(animated: true)
    }
}

extension UberBizViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    private func hideBackButtonTitle(){
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: UIControl.State.highlighted)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        guard let fileUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL else { return }
        self.didImagePicked(image: image, fileName: fileUrl.lastPathComponent)
        
        self.hideBackButtonTitle()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        
        self.hideBackButtonTitle()
    }
    
}
