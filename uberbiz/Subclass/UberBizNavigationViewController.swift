//
//  UberBizNavigationViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/01/21.
//

import UIKit

class UberBizNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        let bounds = self.navigationBar.bounds
//        self.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + 100)
//        navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height + 100)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
