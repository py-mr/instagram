//
//  LoginViewController.swift
//  Instagram
//
//  Created by A I on 2023/11/24.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

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
        //★addressもnilではないし, passwordもnilではない場合なのに・・・？
        if let address = mailAddressTextField.text, let password = passwordTextField.text {

             // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
             if address.isEmpty || password.isEmpty {
                 SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                 return
             }

             // HUDで処理中を表示
             SVProgressHUD.show()

            //★この中には絶対入るの？
             Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
                 if let error = error {
                     print("DEBUG_PRINT: " + error.localizedDescription)
                     SVProgressHUD.showError(withStatus: "サインインに失敗しました。")
                     return
                 }
                 print("DEBUG_PRINT: ログインに成功しました。")

                 // HUDを消す
                 SVProgressHUD.dismiss()

                 // 画面を閉じてタブ画面に戻る
                 self.dismiss(animated: true, completion: nil)
             }
         }
    }
    // アカウント作成ボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleCreateAccountButton(_ sender: Any) {
         //★mailAddressTextField.textはnil許容型（Optional）なのでnilの可能性もある。mailAddressTextField.textがnilでない場合、mailAddressTextField.textをアンラップして、nil非許容型（非Optional）のaddressに入れます。それができた場合、という意味。まあつまり、mailAddressTextField.textがnilでない場合にそれをaddress（非Optional）に入れますということ。??nilじゃないんじゃないの・・・？
        //★これって、OR条件？
        if let address = mailAddressTextField.text, let password = passwordTextField.text, let displayName = displayNameTextField.text {
            // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty || displayName.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
                return
            }
            
            // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
            Auth.auth().createUser(withEmail: address, password: password) { authResult, error in
                //★errorがnilでなかったら
                if let error = error {
                    // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                    print("DEBUG_PRINT: " + error.localizedDescription)
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
                            //★PWが6文字以上でないとというのは、設定できる？
                            print("DEBUG_PRINT: " + error.localizedDescription)
                            return
                        }
                        print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")

                        // 画面を閉じてタブ画面に戻る
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            
            
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
