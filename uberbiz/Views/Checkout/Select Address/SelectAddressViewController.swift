//
//  SelectAddressViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 11/01/21.
//

import UIKit

protocol SelectAddressProtocol {
    func didAddressTapped()
    func didEditTapped()
}

class SelectAddressViewController: UIViewController {

    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var searchView: UIView!
    @IBOutlet var addressTableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupNavigationBar()
    }
    
    private func setupViews(){
        self.title = "Address"
        self.addressTableView.register(UINib(nibName: "SelectAddressTableViewCell", bundle: nil), forCellReuseIdentifier: "AddressCell")
        
        self.searchView.layer.cornerRadius = self.searchView.frame.height/2
        self.searchView.layer.borderWidth = 1
        self.searchView.layer.borderColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.25).cgColor
    }
    
    private func setupNavigationBar(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didNewAddressTapped(_:)))
        let newAddressButton = UIButton(frame: CGRect.zero)
        newAddressButton.setTitle("+ New Address", for: .normal)
        newAddressButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        newAddressButton.setTitleColor(Color.PRIMARY_COLOR, for: .normal)
        newAddressButton.addGestureRecognizer(tapGesture)
        newAddressButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: newAddressButton)
    }
    
    @objc func didNewAddressTapped(_ sender:UIButton){
        self.navigationController?.pushViewController(AddAddressViewController(), animated: true)
    }
    
}

extension SelectAddressViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath) as! SelectAddressTableViewCell
        cell.delegate = self
        return cell
    }
}

extension SelectAddressViewController: SelectAddressProtocol{
    
    func didEditTapped() {
        self.navigationController?.pushViewController(AddAddressViewController(), animated: true)
    }
    
    func didAddressTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
