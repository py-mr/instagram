//
//  MyPageViewController.swift
//  Instagram
//
//  Created by A I on 2023/12/24.
//

import UIKit
import FirebaseAuth
import SVProgressHUD
import FirebaseStorageUI


class MyPageViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 表示名を取得してnavigationBarに設定する（アプリを起動したまま別アカウントにログインし直したような場合を考慮）
        let user = Auth.auth().currentUser
        if let user = user {
            //ナビゲーションバーの表示
            navigationItem.title = user.displayName
        }
        //let date //dateが大きい方を取得
        if let user = user {
            // 画像の表示
            profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            var imageRef = Storage.storage().reference().child(Const.ProfileImagePath)
            let storageReference = Storage.storage().reference().child(Const.ProfileImagePath).child(user.uid)
            storageReference.listAll(completion: { result,error in
                if let error = error {
                    print(error)
                        return
                }
                if let result = result {
                    for item in result.items {
                        // The items under storageReference.
                        imageRef = item
                    }
                }
                self.profileImageView.sd_setImage(with: imageRef)
            })
        }
        
    }
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
