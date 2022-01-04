//
//  ForgotPasswordSuccessViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 26/01/21.
//

import UIKit

class ForgotPasswordSuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func finishAction(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}
