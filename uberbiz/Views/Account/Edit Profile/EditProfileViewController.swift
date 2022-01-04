//
//  EditProfileViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/01/21.
//

import UIKit

class EditProfileViewController: UberBizViewController {

    @IBOutlet var profileImageView: UIImageView!
    
    @IBOutlet var birthdateTextField: UITextField!
    @IBOutlet var genderTextField: UITextField!
    
    private var birthdateDatePicker = UIDatePicker()
    
    private var genderPickerView = UIPickerView()
    private var gender = ["Man", "Woman"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit Profile"
        self.setupViews()
    }
    
    private func setupViews(){
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
        
        self.birthdateDatePicker.datePickerMode = .date
        self.birthdateDatePicker.timeZone = TimeZone.current
        if #available(iOS 13.4, *) {
            self.birthdateDatePicker.preferredDatePickerStyle = .wheels
        }
        self.birthdateDatePicker.addTarget(self, action: #selector(self.datePickerAction(_:)), for: .valueChanged)
        self.birthdateTextField.inputView = self.birthdateDatePicker
        self.birthdateTextField.tintColor = .clear
        
        self.genderPickerView.delegate = self
        self.genderTextField.text = self.gender[0]
        self.genderTextField.inputView = genderPickerView
        self.genderTextField.tintColor = .clear
                
    }
    
    @objc private func datePickerAction(_ sender:UIDatePicker){
        let dateString = DateHelper.shared.formatDate(dateFormat: "dd MMMM yyyy", date: sender.date, timezone: TimeZone.current)
        self.birthdateTextField.text = dateString
    }
    
    @IBAction func changePictureAction(_ sender: Any) {
        print("CHANGE PICTURE")
    }
    
    @IBAction func saveAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension EditProfileViewController:UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.gender[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.genderTextField.text = self.gender[row]
    }
}
