//
//  PostData.swift
//  Instagram
//
//  Created by A I on 2023/12/15.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileData: NSObject {
    var name = ""
    var introduction = ""

    init(document: QueryDocumentSnapshot) {
        let profileDic = document.data()

        if let name = profileDic["name"] as? String {
            self.name = name
        }
        
        if let introduction = profileDic["introduction"] as? String {
            self.introduction = introduction
        }
    }

    override var description: String {
        return "ProfileData: introduction=\(introduction);"
    }
}
