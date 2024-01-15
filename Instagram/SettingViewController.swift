//
//  SettingViewController.swift
//  Instagram
//
//  Created by A I on 2023/11/24.
//

import UIKit
import FirebaseAuth
import SVProgressHUD
import FirebaseStorageUI
import FirebaseFirestore

class SettingViewController: UIViewController {
    var image: UIImage!
    var FromHomeToSetting = ""
    var profileData:ProfileData!
    var name = ""
    var introduction = ""
    var imageSelectViewController: ImageSelectViewController!

    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var introductionTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func textDidChange(_ textField: UITextField) {
        registerButton.isEnabled = true
        let image = UIImage(named: "btn") // btnという名前の画像
        registerButton.setBackgroundImage(image, for: .normal)
    }
    
    //アプリを起動したまま別アカウントにログインし直したような場合を考慮して新しいアカウントの表示名をこの画面のUITextFieldに反映する必要があるため、viewDidLoad() ではなく viewWillAppear(_:)で実施
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        registerButton.isEnabled = false
        registerButton.setBackgroundImage(nil, for: .normal)
        registerButton.backgroundColor = UIColor.gray
        
        //変更を検知したらボタンの色を変える
        displayNameTextField.addTarget(self,action: #selector(textDidChange),for: .editingChanged)
        introductionTextField.addTarget(self,action: #selector(textDidChange),for: .editingChanged)
        
        // 表示名を取得してTextFieldに設定する
        let user = Auth.auth().currentUser
        //let date //dateが大きい方を取得
        if let user = user {
            //タブバーから来た場合：登録されているもの
            //if self.tabBarController != nil {
                // 名前の表示
                displayNameTextField.text = user.displayName
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
                    // 角丸にする
                    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width * 0.5
                    self.profileImageView.clipsToBounds = true
                })
                
                //自己紹介の表示
                Firestore.firestore().collection(Const.ProfileIntroductionPath).document(user.uid).getDocument(completion: { result,error in
                    if let error = error {
                        print(error)
                        return
                    } else {
                        let text = result!.data()!["introduction"] as! String
                        print(text)
                        self.introductionTextField.text = text
                    }
                })
            //imageselectViewから来た場合：そこで選択されたもの（★ここにこない）
            /*} else {
                // 名前の表示（imageSelectViewに渡して、imageSelectViewから返してもらう）
                displayNameTextField.text = name
                // 受け取った画像をImageViewに設定する
                profileImageView.image = image
                // 自己紹介の表示（imageSelectViewに渡して、imageSelectViewから返してもらう）
                introductionTextField.text = introduction
                
            }*/
        }
    }
    
    @IBAction func handleChangeButton(_ sender: Any) {
        if let displayName = displayNameTextField.text {

            // 表示名が入力されていない時はHUDを出して何もしない
            if displayName.isEmpty {
                SVProgressHUD.showError(withStatus: "表示名を入力して下さい")
                return
            }

            // 登録情報を更新する
            let user = Auth.auth().currentUser
            if let user = user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges { error in
                    if let error = error {
                        SVProgressHUD.showError(withStatus: "表示名の変更に失敗しました。")
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        return
                    }
                    print("DEBUG_PRINT: [displayName = \(user.displayName!)]の登録情報に成功しました。")
                    // HUDで完了を知らせる
                    //SVProgressHUD.showSuccess(withStatus: "登録情報を変更しました")
                }
                
                // 画像をJPEG形式に変換する
                let date = getToday()
                let imageData:Data?
                //imageに何も入っていない場合（Tabから遷移してきた場合）
                if image == nil {
                    imageData = profileImageView.image!.jpegData(compressionQuality: 0.75)
                //imageに何か入っている場合（imageSelectViewから受けっとっている場合）
                } else {
                    imageData = image.jpegData(compressionQuality: 0.75)
                }
                // 画像と投稿データの保存場所を定義する
                let imageRef = Storage.storage().reference().child(Const.ProfileImagePath).child(user.uid).child(date + ".jpg")
                
                // HUDで投稿処理中の表示を開始
                SVProgressHUD.show()
                // Storageに画像をアップロードする
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                imageRef.putData(imageData!, metadata: metadata) { (metadata, error) in
                    if error != nil {
                        // 画像のアップロード失敗
                        print(error!)
                        SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                        // 投稿処理をキャンセルし、先頭画面に戻る
                        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                        return
                    }
                    
                    //自己紹介文を入力する
                    // Profileに更新データを書き込む
                    let profileRef = Firestore.firestore().collection(Const.ProfileIntroductionPath).document(user.uid)
                    /*let profileDic = [
                        "introduction": self.introductionTextField.text!,
                        ] as [String : Any]*/
                    profileRef.updateData([
                        "name": self.displayNameTextField.text!,
                        "introduction": self.introductionTextField.text!,
                        ])
                    print(user.uid)

                    // HUDで投稿完了を表示する
                    SVProgressHUD.showSuccess(withStatus: "登録情報を変更しました")
                    
                    // 投稿処理が完了したので先頭画面に戻る
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                    
                }
                
            }
        }
        
        func getToday(format:String = "yyyyMMddHHmm") -> String {
                let now = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = format
                return formatter.string(from: now as Date)
        }

        
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    @IBAction func onTapImage(_ sender: Any) {
        // セグエを使用して画面を遷移
        performSegue(withIdentifier: "imageSegue", sender: nil)
        //profileImageView.image = image
    
    }
    
    //画面遷移から戻ってきたときに実行する関数
    func callBack(image: UIImage) {
        self.profileImageView.image = image //設定でAspect Fillにした
        // 角丸にする
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width * 0.5
        self.profileImageView.clipsToBounds = true
        
        registerButton.isEnabled = true
        let image = UIImage(named: "btn") // btnという名前の画像
        registerButton.setBackgroundImage(image, for: .normal)
    }
      
    @IBAction func handleLogoutButton(_ sender: Any) {
        // ログアウトする
        try! Auth.auth().signOut()

        // ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        self.present(loginViewController!, animated: true, completion: nil)

        // ログイン画面から戻ってきた時のためにホーム画面（index = 0）を選択している状態にしておく
        tabBarController?.selectedIndex = 0
        
        // 通知を送りたい箇所でこのように記述
        NotificationCenter.default.post(name: .notifyName, object: nil)
        
        //SettingViewを初期化する
        //プロフ画像を初期化（デフォルトの画像にする）
        //let imageData = UIImage(systemName: "person.circle.fill")!.withTintColor(UIColor.orange)
        let imageData = UIImage(named: "face")
        self.profileImageView.image = imageData
        //表示名を初期化
        self.displayNameTextField.text = ""
        //自己紹介文を初期化
        self.introductionTextField.text = ""
    }
    
    //segueで画面遷移する時に呼ばれる。segueはキックされている。performSegueでどのsegueをキックするかを指定
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imageSegue" {
            //segueから遷移先のInputViewControllerを取得する
            let imageSelectViewController:ImageSelectViewController = segue.destination as! ImageSelectViewController
            imageSelectViewController.parentSettingViewController = self
            
            //imageSelectViewController.segueId = "FromSetting"
            imageSelectViewController.trasitionType = .fromSetting
            imageSelectViewController.name = displayNameTextField.text!
            imageSelectViewController.introduction = introductionTextField.text!
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
