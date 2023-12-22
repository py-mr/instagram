//
//  PostData.swift
//  Instagram
//
//  Created by A I on 2023/12/15.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PostData: NSObject {
    var id = ""
    var name = ""
    var caption = ""
    var date = ""
    var likes: [String] = []
    var isLiked: Bool = false
    var comments:String = ""

    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID

        let postDic = document.data()

        if let name = postDic["name"] as? String {
            self.name = name
        }

        if let caption = postDic["caption"] as? String {
            self.caption = caption
        }

        if let timestamp = postDic["date"] as? Timestamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            self.date = formatter.string(from: timestamp.dateValue())
        }

        if let likes = postDic["likes"] as? [String] {
            self.likes = likes
        }

        if let myid = Auth.auth().currentUser?.uid {
            // likesの配列の中にmyidが含まれているかチェックすることで、自分がいいねを押しているかを判断
            if self.likes.firstIndex(of: myid) != nil {
                // myidがあれば、いいねを押していると認識する。
                self.isLiked = true
            }
        }
        
        var commentsLine = ""
        var commentArray:[String] = []
        if let comments = postDic["comments"] as? Array<Any> {
            // データを1件ずつ抽出
            for cm in 0 ..< comments.count {
                let dicData = comments[cm] as! [String : Any]
                let nameData = dicData["name"] as! String
                let commentData = dicData["comment"] as! String
                let array = nameData + " : " + commentData
                commentArray += [array]
                commentsLine = commentsLine + commentArray[cm] + "\n"
            }
            self.comments = commentsLine
        }
    }

    override var description: String {
        return "PostData: name=\(name); caption=\(caption); date=\(date); likes=\(likes.count); id=\(id); comments=\(comments);"
    }
}
