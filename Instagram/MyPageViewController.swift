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
import FirebaseFirestore


//class MyPageViewController: UIViewController {
class MyPageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var postCount: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var introductionLabel: UILabel!
    
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    
    var myPostData: PostData?
    // Firestoreのリスナー
    var listener: ListenerRegistration?
    
    var homeViewController: HomeViewController?
    
    // レイアウト設定　UIEdgeInsets については下記の参考図を参照。
    //private let sectionInsets = UIEdgeInsets(top: 10.0, left: 2.0, bottom: 2.0, right: 2.0)
    // 1行あたりのアイテム数
    //private let itemsPerRow: CGFloat = 2

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "MyPostCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "MyCell")
        
        // レイアウト設定
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 130, height: 130)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        collectionView.collectionViewLayout = layout
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
            // プロフィール画像の表示
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
                /*
                self.profileImageView.sd_setImage(with: imageRef)
                let profileImage = self.profileImageView.image
                if profileImage != nil {
                    self.profileImageView.image = profileImage?.trimming()
                    //self.profileImageView.image = self.profiletrimming(image: profileImage!)
                    // 角丸にする
                    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width * 0.5
                    self.profileImageView.clipsToBounds = true
                } else {
                    //何もしない
                }
                */
                self.profileImageView.sd_setImage(with: imageRef, placeholderImage: nil, completion: { (image, error, cacheType, url) in
                    if let error = error {
                        // エラー処理
                        print("画像のダウンロードに失敗しました: \(error.localizedDescription)")
                    } else {
                        // 画像のダウンロードとセットアップが完了した処理
                        if image != nil {
                            //self.myPostImageView.image = self.trimming(image: myPostImage!)
                            self.profileImageView.image = image?.trimming()
                            // 角丸にする
                            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width * 0.5
                            self.profileImageView.clipsToBounds = true
                        } else {
                            //何もしない
                        }
                        print("画像が正常にセットされました")
                    }
                })
                
                
            })
            
            
            
            //自己紹介の表示
            Firestore.firestore().collection(Const.ProfileIntroductionPath).document(user.uid).getDocument(completion: { result,error in
                if let error = error {
                    print(error)
                    return
                } else {
                    let text = result!.data()!["introduction"] as! String
                    print(text)
                    self.introductionLabel.text = text
                }
            })
            
            //投稿データの表示
            // listenerを登録して投稿データの更新を監視する
            let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true).whereField("userId", isEqualTo: user.uid)
            listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                self.postArray = querySnapshot!.documents.map { document in
                    let postData = PostData(document: document)
                    //print("DEBUG_PRINT: \(postData.name)")
                    return postData
                }
                // collectionViewの表示を更新する
                self.collectionView.reloadData()
                
                //投稿数を取得（画像の数でいいや・・・★）
                self.postCount.text = String(self.postArray.count)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        // listenerを削除して監視を停止する
        listener?.remove()
        // TableViewの表示を更新する
        self.collectionView.reloadData()
    }
    
    //セルの数を指定する
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postArray.count
    }
    
    //セルの中身を指定する
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // セルを取得してデータを設定する
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! MyPostCollectionViewCell
        cell.setMyPostData(postArray[indexPath.row])
        return cell
    }
    
    /*
    // Screenサイズに応じたセルサイズを返す
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem , height: widthPerItem + 42)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // セルの行間の設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
     */
    // セルが選択されたときの処理
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 配列からタップされたインデックスのデータを取り出す
        myPostData = postArray[indexPath.row]
        print(myPostData!)
        //★Homeへ遷移（Segue）。Homeへ値（id）を渡す。Home側では、そのidをもとにindexPath.rowを取得。で、そこにスクロール。
        //★なんでだめなんだ
        //let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyPageToHomeSegue") as! HomeViewController
        //homeViewController.documentId = myPostData!.id
        performSegue(withIdentifier: "MyPageToHomeSegue", sender: nil)
    }
    
    //segueで画面遷移する時に呼ばれる。segueはキックされている。performSegueでどのsegueをキックするかを指定
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MyPageToHomeSegue" {
            //myPostDataのidを渡す
            let homeViewController = segue.destination as! HomeViewController
            homeViewController.documentId = myPostData!.id
        }
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
