//
//  SearchListingViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/01/21.
//

import UIKit
import IQKeyboardManagerSwift

protocol SearchHistoryDelegate {
    func didClearHistory()
}

class SearchHistoryViewController: UberBizViewController {

//    @IBOutlet var searchListingCollectionView: UICollectionView!
    @IBOutlet var searchHistoryTableV: UITableView!
    
    private var searchHistories: [String] = []
    var delegate: TabBarDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupData()
        self.setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    private func setupViews(){
        self.searchHistoryTableV.register(UINib(nibName: "SearchHistoryHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchHistoryHeaderCell")
        self.searchHistoryTableV.register(UINib(nibName: "SearchHistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchHistoryCell")
    }
    
    private func setupData(){
        self.searchHistories = UserDefaultHelper.shared.getSearchHistories()
    }
    
    private func setupNavigationBar(){
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.frame.size.width)!, height: 35))
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.init(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.25).cgColor
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .white
        textField.leftViewMode = .always
        textField.delegate = self
        textField.returnKeyType = .search
        
        let searchV = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: textField.frame.height))
        let searchIV = UIImageView(image: UIImage(named: "search-icon"))
        searchIV.frame = CGRect(x: 12, y: ((searchV.frame.height - 17)/2), width: 17, height: 17)
        searchV.addSubview(searchIV)
        textField.leftView = searchV
        
        textField.rightViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 45))
        textField.layer.cornerRadius = textField.frame.height/2
        textField.becomeFirstResponder()
        self.navigationItem.titleView = textField
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 16))
        let notifTapGesture = UITapGestureRecognizer(target: self, action: #selector(didNotifTapped(_:)))
        
        let backIV = UIImageView(image: UIImage(named: "chevron-left-icon"))
        backIV.frame = CGRect(x: 0, y: 0, width: 10, height: 16)
        view.addGestureRecognizer(notifTapGesture)

        view.addSubview(backIV)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    @objc func didNotifTapped(_ sender: UIButton){
        self.delegate?.didSearchHistoryDismissed()
        self.navigationController?.popViewController(animated: true)
    }
}

extension SearchHistoryViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        return self.searchHistories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchHistoryHeaderCell", for: indexPath) as! SearchHistoryHeaderTableViewCell
            cell.delegate = self
            if searchHistories.count == 0{
                cell.clearHistoryBtn.isHidden = true
            }else{
                cell.clearHistoryBtn.isHidden = false
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchHistoryCell", for: indexPath) as! SearchHistoryTableViewCell
        cell.searchQueryL.text = self.searchHistories[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            let searchListingVC = SearchListingViewController()
            searchListingVC.searchQuery = self.searchHistories[indexPath.item]
            self.navigationController?.pushViewController(searchListingVC, animated: true)
        }
    }
}

extension SearchHistoryViewController: SearchHistoryDelegate{
    func didClearHistory() {
        self.searchHistories.removeAll()
        UserDefaultHelper.shared.clearSearchHistory()
        
        self.searchHistoryTableV.reloadData()
    }
}

extension SearchHistoryViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let searchListingVC = SearchListingViewController()
        searchListingVC.searchQuery = textField.text!
        self.navigationController?.pushViewController(searchListingVC, animated: true)
        
        /// Exit When String Already on Search History
        for history in UserDefaultHelper.shared.getSearchHistories() {
            if textField.text!.uppercased() == history.uppercased(){
                return true
            }
        }
        
        UserDefaultHelper.shared.updateSearchHistory(searchQuery: textField.text!)
        self.searchHistories = UserDefaultHelper.shared.getSearchHistories()
        self.searchHistoryTableV.reloadData()
        
        return true
    }
}
