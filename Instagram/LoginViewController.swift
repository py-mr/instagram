//
//  LoginViewController.swift
//  Instagram
//
//  Created by A I on 2023/11/24.
//

import UIKit
import FirebaseAuth
import SVProgressHUD
import FirebaseStorage
import FirebaseFirestore

class LoginViewController: UIViewController {

    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // ログインボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleLoginButton(_ sender: Any) {
        //★mailAddressTextField.textもnilではないし, passwordTextField.textもnilではない場合なのに・・・？
        if let address = mailAddressTextField.text, let password = passwordTextField.text {

             // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
             if address.isEmpty || password.isEmpty {
                 SVProgressHUD.showError(withStatus: "メールアドレスとパスワードを入力して下さい")
                 return
             }

             // HUDで処理中を表示
             SVProgressHUD.show()

            //ログイン
             Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
                 if let error = error {
                     print("DEBUG_PRINT: " + error.localizedDescription)
                     SVProgressHUD.showError(withStatus: "サインインに失敗しました。")
                     return
                 }
                 SVProgressHUD.showSuccess(withStatus: "ログインに成功しました。")
                 //print("DEBUG_PRINT: ログインに成功しました。")

                 // HUDを消す
                 //成功HUDが出た0.5秒後にHUD削除と画面遷移
                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                 // 0.5秒後に実行したい処理
                     SVProgressHUD.dismiss()
                 // 画面を閉じてタブ画面に戻る
                 self.dismiss(animated: true, completion: nil)
                 }
             }
         }
    }
    
    // アカウント作成ボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleCreateAccountButton(_ sender: Any) {
         //★mailAddressTextField.textはnil許容型（Optional）なのでnilの可能性もある。mailAddressTextField.textがnilでない場合、mailAddressTextField.textをアンラップして、nil非許容型（非Optional）のaddressに入れます。それができた場合、という意味。まあつまり、mailAddressTextField.textがnilでない場合にそれをaddress（非Optional）に入れますということ。??nilじゃないんじゃないの・・・？
        //★これって、OR条件？⇨AND。カンマの場合AND。
        //⇨文字列のnilとisEmpty（""）は別。nilになることは基本的にないが、textがOptional型なのでアンラップせざるをえないのでやっている。本来nilでなく""でないというのは一緒にチェックすべき。mailAddressTextField.text!.isEmptyでもいいが、、!はつけない。強制アンラップになるので、アンラップ成功するかどうかを考えたくない。if letでアンラップに失敗してもelseに流れるので、落ちることはないから。
        if let address = mailAddressTextField.text, let password = passwordTextField.text, let displayName = displayNameTextField.text {
            // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty || displayName.isEmpty {
                SVProgressHUD.showError(withStatus: "全項目を入力してください。")
                //print("DEBUG_PRINT: 何かが空文字です。")
                return
            }
            
            // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
            Auth.auth().createUser(withEmail: address, password: password) { authResult, error in
                //★errorがnilでなかったら
                if let error = error {
                    // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    //print("DEBUG_PRINT: " + error.localizedDescription)
                    return
                }
                print("DEBUG_PRINT: ユーザー作成に成功しました。")

                // 表示名を設定する
                //★currentUserって、Auth.auth().createUserでクリエイトしてできたuser？
                let user = Auth.auth().currentUser
                //★上のuserがnilでなかった場合
                if let user = user {
                    //★クリエイトしてできたuser（メアドとPWのみ）のプロファイルを更新する（ここでnameを入れる）
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            // プロフィールの更新でエラーが発生
                            //★PWが6文字以上でないとというのは、バリデーションとして設定してよいか？⇨こっちでやってOK。ただ、FireStore側のに追従しないといけない。追従したくないのでエラー要因は出したくない。”認証時にエラー、、”とか出すだけで。PW要因かどうかも言いたくない。mailAddressTextField.textってのはあんまやるのは。。if文とかにしておいて予期せぬエラーにする
                            SVProgressHUD.showError(withStatus: error.localizedDescription)
                            //print("DEBUG_PRINT: " + error.localizedDescription)
                            return
                        }
                        
                        // HUDで投稿処理中の表示を開始
                        SVProgressHUD.show()
                        
                        let userId = (Auth.auth().currentUser?.uid)!
                        let date = getToday()
                        let imageData = UIImage(systemName: "person.circle.fill")!.withTintColor(UIColor.orange).jpegData(compressionQuality: 0.75)
                        let imageRef = Storage.storage().reference().child(Const.ProfileImagePath).child(userId).child( date + ".jpg")
                        print(date)
                        // Storageに画像をアップロードする
                        let metadata = StorageMetadata()
                        metadata.contentType = "image/jpeg"
                        imageRef.putData(imageData!, metadata: metadata) { (metadata, error) in
                            if error != nil {
                                print(error!)
                                SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                                // 投稿処理をキャンセルし、先頭画面に戻る
                                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                                return
                            }
                        }
                        
                        // Profileに更新データを書き込む
                        let profileRef = Firestore.firestore().collection(Const.ProfileIntroductionPath).document(userId)
                        let profileDic = [
                            "name" : displayName,
                            "introduction": "",
                            ] as [String : Any]
                        profileRef.setData(profileDic)
                        
                        print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                        // HUDで投稿完了を表示する
                        SVProgressHUD.showSuccess(withStatus: "登録完了しました")
                        // 画面を閉じてタブ画面に戻る
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            
            
        }

        func getToday(format:String = "yyyyMMddHHmm") -> String {
                let now = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = format
                return formatter.string(from: now as Date)
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
