//
//  ImageCollectionViewCell.swift
//  ushur_sdk_demo
//
//  Created by mymac on 24/07/23.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    public var deleteCompletionBlock:((Bool)->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        imgView.contentMode = .scaleAspectFill
    }
    
    @IBAction func onDeleteTapped(_ sender: UIButton) {
        if let deleteCompletionBlock = deleteCompletionBlock {
            deleteCompletionBlock(true)
        }
    }
    

}
