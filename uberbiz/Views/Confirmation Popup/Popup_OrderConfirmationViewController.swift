//
//  Popup_OrderConfirmationViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 30/03/21.
//

import UIKit

class Popup_OrderConfirmationViewController: UIViewController {

    @IBOutlet var containerV: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }

    private func setupViews(){
        self.containerV.layer.cornerRadius = 15
    }

}
