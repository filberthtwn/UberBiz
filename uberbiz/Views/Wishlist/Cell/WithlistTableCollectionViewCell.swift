//
//  WithlistTableCollectionViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 06/01/21.
//

import UIKit

class WithlistTableCollectionViewCell: UICollectionViewCell {

    @IBOutlet var wishlistTableView: UITableView!
    
    var delegate: WishlistProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    private func setupViews(){
        
        self.wishlistTableView.delegate = self
        self.wishlistTableView.dataSource = self
        
        self.wishlistTableView.register(UINib(nibName: "WishlistTableViewCell", bundle: nil), forCellReuseIdentifier: "WishlistCell")
    }

}

extension WithlistTableCollectionViewCell: UITableViewDelegate, UITableViewDataSource{
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WishlistCell", for: indexPath)
        return cell
    }
}
