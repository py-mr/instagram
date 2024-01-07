//
//  UIImage+extension.swift
//  Instagram
//
//  Created by A I on 2024/01/06.
//

import UIKit

extension UIImage {
    func trimming() -> UIImage {
        //https://www.yoheim.net/blog.php?q=20120503
        //切り抜く位置を指定するCGRectを作成する。
        //画像の中心部分を120*160で切り取る。
        var posX: CGFloat
        var posY: CGFloat
        var trimArea: CGRect
        if self.size.width > self.size.height {
            posX = (self.size.width - self.size.height)/2
            posY = 0
            trimArea = CGRectMake(posX, posY, self.size.height, self.size.height)
        } else {
            posX = 0
            posY = (self.size.height - self.size.width)/2
            trimArea = CGRectMake(posX, posY, self.size.width, self.size.width)
        }
        // CoreGraphicsの機能を用いて、切り抜いた画像を作成する。
        var srcImageRef: CGImage
        var trimmedImageRef: CGImage
        var trimmedImage: UIImage
        srcImageRef = self.cgImage!
        trimmedImageRef = srcImageRef.cropping(to: trimArea)!
        //trimmedImage = trimmedImageRef as! UIImage
        trimmedImage = UIImage(cgImage: trimmedImageRef)
        return trimmedImage
    }
}
