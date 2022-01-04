//
//  ImagePreviewViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 19/02/21.
//

import UIKit

class ImagePreviewViewController: UIViewController {

    @IBOutlet var contentV: UIView!
    @IBOutlet var deleteV: UIView!
    @IBOutlet var photoIV: UIImageView!
    
    var image: UIImage = UIImage(named: "img_placeholder")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        // Do any additional setup after loading the view.
    }
    
    private func setupViews(){
        
        self.contentV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didBackgroundTapped(_:))))
        
        self.deleteV.layer.cornerRadius = self.deleteV.frame.height/2
        self.photoIV.layer.cornerRadius = 10
        self.photoIV.image = self.image
    }
    
    @objc private func didBackgroundTapped(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
