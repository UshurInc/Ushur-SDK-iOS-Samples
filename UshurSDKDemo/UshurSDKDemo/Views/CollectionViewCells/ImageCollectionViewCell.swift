//  Copyright 2023. All rights reserved.

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteImageBtn: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
