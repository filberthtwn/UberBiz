//
//  TabBarViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 04/01/21.
//

import UIKit

struct TabBarSource {
    static let REQUEST = "REQUEST"
}

struct TabBarItem {
    static var sourceVC:String?
}

protocol TabBarDelegate {
    func didSearchHistoryDismissed()
}

class TabBarViewController: UberBizViewController {
    
    private var viewControllers: [UIViewController]!
    
    @IBOutlet var mainCollectionView: UICollectionView!
    
    @IBOutlet var tabBarIcons: [UIImageView]!
    @IBOutlet var tabBarLabels: [UILabel]!
    
    private var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        self.setupNavigationBar()
        self.updateTabBar(currentIndex: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if TabBarItem.sourceVC == TabBarSource.REQUEST{
            self.mainCollectionView.selectItem(at: IndexPath(row: 1, section: 0), animated: false, scrollPosition: .left)
            self.updateTabBar(currentIndex: 1)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        TabBarItem.sourceVC = nil
    }
    
    private func setupViews(){
        self.viewControllers = [HomeViewController(), MessengerViewController(), AccountViewController()]
        self.mainCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    }
    
    private func setupNavigationBar(){
        
        self.navigationController?.navigationBar.shadowImage = UIImage()    
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 56, height: 24))
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 56, height: 24))
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        let notifTapGesture = UITapGestureRecognizer(target: self, action: #selector(didNotifTapped(_:)))
        let notifButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        notifButton.setImage(UIImage(named: "bell-icon"), for: .normal)
        notifButton.addGestureRecognizer(notifTapGesture)

        let heartTapGesture = UITapGestureRecognizer(target: self, action: #selector(didWishlistTapped(_:)))
        let heartButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        heartButton.setImage(UIImage(named: "heart-icon"), for: .normal)
        heartButton.addGestureRecognizer(heartTapGesture)
        
        stackView.addArrangedSubview(heartButton)
        stackView.addArrangedSubview(notifButton)
        
        view.addSubview(stackView)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: view)
        
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.frame.size.width)!-108 , height: 30))
        textField.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(didTextFieldEditingBegin(_:))))
        textField.isEnabled = false
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.init(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.25).cgColor
        textField.placeholder = "Temukan Produk/Jasa"
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .white
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 45))
        textField.rightViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 45))
        textField.layer.cornerRadius = 6
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: textField)
    }
    
    @objc func didTextFieldEditingBegin(_ sender: UITextField){
        let searchListingVC = SearchHistoryViewController()
        searchListingVC.delegate = self
        self.navigationController?.pushViewController(searchListingVC, animated: false)
    }
    
    @objc func didNotifTapped(_ sender: UIButton){
        self.navigationController?.pushViewController(NotificationViewController(), animated: true)
    }
    
    @objc func didWishlistTapped(_ sender: UIButton){
        self.navigationController?.pushViewController(WishlistViewController(), animated: true)
    }

    @IBAction func didPressTab(_ sender: UIButton) {
        self.mainCollectionView.selectItem(at: IndexPath(row: sender.tag, section: 0), animated: true, scrollPosition: .left)
        self.updateTabBar(currentIndex: sender.tag)
    }
    
    private func updateTabBar(currentIndex:Int){
        let previousIndex = selectedIndex
        tabBarLabels[previousIndex].textColor = Color.TABBAR_INACTIVE_COLOR
        tabBarIcons[previousIndex].tintColor = Color.TABBAR_INACTIVE_COLOR
        
        self.selectedIndex = currentIndex
        tabBarLabels[selectedIndex].textColor = Color.PRIMARY_COLOR
        tabBarIcons[selectedIndex].tintColor = Color.PRIMARY_COLOR
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let selectedPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        self.updateTabBar(currentIndex: selectedPage)
    }
}

extension TabBarViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.mainCollectionView.frame.width, height: self.mainCollectionView.frame.height)
    }
}

extension TabBarViewController:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == selectedIndex {
//            if let homeVC = viewControllers[selectedIndex] as? HomeViewController{
//                homeVC.view.removeFromSuperview()
//            }
            
            if let messengerVC = viewControllers[selectedIndex] as? MessengerViewController{
                messengerVC.setupData(index: 0)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewControllers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let viewController = self.viewControllers[indexPath.row]
        viewController.view.frame = self.mainCollectionView.frame
        
        addChild(viewController)
        
        cell.addSubview(viewController.view)
        
        return cell
    }
    
}

extension TabBarViewController: TabBarDelegate{
    func didSearchHistoryDismissed() {
        self.mainCollectionView.reloadData()
    }
}
