//
//  MyPostCollectionViewCell.swift
//  Instagram
//
//  Created by A I on 2024/01/02.
//

import UIKit
import FirebaseStorageUI

class MyPostCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var myPostImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
        // 画像の表示
        myPostImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        myPostImageView.sd_setImage(with: imageRef)
    }
    
}
