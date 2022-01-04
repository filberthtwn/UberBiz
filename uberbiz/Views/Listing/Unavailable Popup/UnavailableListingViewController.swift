//
//  UnavailableListingViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 21/02/21.
//

import UIKit

protocol UnavailableListingProtocol {
    func didDismiss()
}

class UnavailableListingViewController: UIViewController {

    @IBOutlet var contentV: UIView!
    
    var delegate: UnavailableListingProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    private func setupViews(){
        self.contentV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissAction(_:))))
    }
    
    @objc private func dismissAction(_ sender: UITapGestureRecognizer){
        
        self.dismiss(animated: false, completion: nil)
        self.delegate?.didDismiss()
    }

}
