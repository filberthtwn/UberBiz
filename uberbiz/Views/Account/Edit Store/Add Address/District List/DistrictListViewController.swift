//
//  DistrictListViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 10/01/21.
//

import UIKit

class DistrictListViewController: UIViewController {

    @IBOutlet var districtTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    private func setupViews(){
        self.title = "Choose District"
        self.districtTableView.register(UINib(nibName: "TextTableViewCell", bundle: nil), forCellReuseIdentifier: "TextCell")
    }

}

extension DistrictListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath)
        return cell
    }
}
