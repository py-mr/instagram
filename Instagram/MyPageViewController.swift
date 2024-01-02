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


//class MyPageViewController: UIViewController {
class MyPageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    private let photos = ["photo0", "photo1", "photo2", "photo3", "photo1", "photo2", "photo0"]
    // レイアウト設定
    private let sectionInsets = UIEdgeInsets(top: 1.0, left: 2.0, bottom: 2.0, right: 2.0)
    // 1行あたりのアイテム数
    private let itemsPerRow: CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        
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
    
    //セルの数を指定する
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return 140
        //return pictureLabels.count
        return photos.count
    }
    
    //セルの中身を指定する（ここでは背景色を指定）
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // "MyCell" の部分は　Storyboard でつけた cell の identifier。
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath)

        // Tag番号を使ってインスタンスをつくる
        let photoImageView = cell.contentView.viewWithTag(1)  as! UIImageView
        let photoImage = UIImage(named: photos[indexPath.row])
        photoImageView.image = photoImage
        // セルに枠線をセット
        cell.layer.borderColor = UIColor.lightGray.cgColor // 外枠の色
        cell.layer.borderWidth = 1.0 // 枠線の太さ

        return cell
    }
    /*
    // Screenサイズに応じたセルサイズを返す
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        print("あああああ")
        return CGSize(width: widthPerItem , height: widthPerItem + 42)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    // セルの行間の設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    // セルが選択されたときの処理
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("tapされたよ")
    }
     */
    
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
