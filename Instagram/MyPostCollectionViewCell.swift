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
    func setMyPostData(_ postData: PostData) {
        // 画像の表示
        myPostImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        /*
        myPostImageView.sd_setImage(with: imageRef)
        let myPostImage = myPostImageView.image
        if myPostImage != nil {
            myPostImageView.image = trimming(image: myPostImage!)
        } else {
            //何もしない
        }
        */
        myPostImageView.sd_setImage(with: imageRef, placeholderImage: nil, completion: { (image, error, cacheType, url) in
            if let error = error {
                // エラー処理
                print("画像のダウンロードに失敗しました: \(error.localizedDescription)")
            } else {
                // 画像のダウンロードとセットアップが完了した処理

                if image != nil {
                    //self.myPostImageView.image = self.trimming(image: myPostImage!)
                    self.myPostImageView.image = image?.trimming()
                } else {
                    //何もしない
                }
                print("画像が正常にセットされました")
            }
        })
    }
}
