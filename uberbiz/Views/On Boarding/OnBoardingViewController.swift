//
//  OnBoardingViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 11/01/21.
//

import UIKit

class OnBoardingViewController: UIViewController {
    
    @IBOutlet var onBoardingCollectionView: UICollectionView!
    @IBOutlet var dotViews: [UIView]!
    @IBOutlet var dotViewsWidth: [NSLayoutConstraint]!
    
    @IBOutlet var skipButton: UIButton!
    @IBOutlet var nextButton: UberBizButton!
    
    private var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    private func setupViews(){
        self.onBoardingCollectionView.register(UINib(nibName: "OnBoardingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OnBoardingCell")
        
        for dotView in self.dotViews {
            dotView.layer.cornerRadius = dotView.layer.frame.height/2
        }
    }
    
    func updateView(){
        for (index, dotViewWidth) in self.dotViewsWidth.enumerated() {
            if (self.selectedIndex == index){
                dotViewWidth.constant = 75
            }else{
                dotViewWidth.constant = 14
            }
        }
        
        if (self.selectedIndex == 2){
            self.skipButton.isHidden = true
            self.nextButton.setTitle("Get Started", for: .normal)
        }else{
            self.skipButton.isHidden = false
            self.nextButton.setTitle("Next", for: .normal)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.selectedIndex = Int(self.onBoardingCollectionView.contentOffset.x/self.view.frame.width)
        self.updateView()
    }
    
    @IBAction func skipAction(_ sender: Any?) {
        self.onBoardingCollectionView.scrollToItem(at: IndexPath(row: 2, section: 0), at: .left, animated: true)
        self.selectedIndex = 2
        self.updateView()
    }
    
    @IBAction func nextAction(_ sender: Any) {
        if (self.selectedIndex == 2){
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
        }else{
            self.selectedIndex = self.selectedIndex + 1
            self.onBoardingCollectionView.scrollToItem(at: IndexPath(row: self.selectedIndex, section: 0), at: .left, animated: true)
            self.updateView()
        }
    }
}

extension OnBoardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.onBoardingCollectionView.frame.width, height: self.onBoardingCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnBoardingCell", for: indexPath)
        return cell
    }
    
    
}
