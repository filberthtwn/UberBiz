//
//  AddProductNewImageCollectionViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 10/01/21.
//

import UIKit

class AddProductNewImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet var addPhotoView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    private func setupViews(){
        let dashedLayer = CAShapeLayer()
        dashedLayer.strokeColor = Color.PRIMARY_COLOR.cgColor
        dashedLayer.lineDashPattern = [5, 5]
        dashedLayer.frame = addPhotoView.bounds
        dashedLayer.fillColor = nil
        dashedLayer.path = UIBezierPath(roundedRect: addPhotoView.bounds, cornerRadius: 6).cgPath
        addPhotoView.layer.addSublayer(dashedLayer)
    }

}
