//
//  PostData.swift
//  Instagram
//
//  Created by A I on 2023/12/15.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CommentData: NSObject {
    var id = ""
    var postId = "" //投稿のID
    var name = ""
    var date = ""
    var comment = ""

    //firestoreからQuery..で取得できる。commentDicに辞書の形ではいている。
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID

        let commentDic = document.data()

        //"postId"⇨Firestoreの値
        if let postId = commentDic["postId"] as? String {
            self.postId = postId
        }
        if let name = commentDic["name"] as? String {
            self.name = name
        }
        if let timestamp = commentDic["date"] as? Timestamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            self.date = formatter.string(from: timestamp.dateValue())
        }
        if let comment = commentDic["comment"] as? String {
            self.comment = comment
        }
    }

    override var description: String {
        return "CommentData: name=\(name); date=\(date); id=\(id); postId=\(postId); comment=\(comment)"
    }
}
