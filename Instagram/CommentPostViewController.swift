//
//  CommentPostViewController.swift
//  Instagram
//
//  Created by A I on 2023/12/20.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD

class CommentPostViewController: UIViewController {
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    var postId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //TextFieldの見た目
        fieldappearance(commentTextField)
        
        //エラーラベルの初期値
        errorLabel.text = ""
        
         // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
         let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
         self.view.addGestureRecognizer(tapGesture)
         
    }
    
    //TextFieldの見た目
    func fieldappearance(_ sender:UITextField) {
        sender.layer.cornerRadius = 5
        sender.layer.borderColor = UIColor.lightGray.cgColor
        sender.layer.borderWidth = 1.0
    }
    
    
    @IBAction func commentPostButton(_ sender: Any) {
        //コメントの文字数バリデーションチェック
        switch validate() {
        case 1:
            commentTextField.layer.borderColor = UIColor.red.cgColor
            errorLabel.text = "入力されていません"
        case 2:
            commentTextField.layer.borderColor = UIColor.red.cgColor
            errorLabel.text = "20文字以上は入力できません"
        default:
            commentTextField.layer.borderColor = UIColor.lightGray.cgColor
            errorLabel.text = ""
        
        // 投稿データの保存場所を定義する
        //Const.swiftで定義した CommentPathを collection(_:)メソッドの引数に指定することで、Firestoreの "comments"フォルダに新しい投稿データを保存するよう指定
        let commentRef = Firestore.firestore().collection(Const.CommentPath).document()
        // HUDで投稿処理中の表示を開始
        SVProgressHUD.show()
        // FireStoreに投稿データを保存する
        let name = Auth.auth().currentUser?.displayName
        let commentDic = [
            "postId": postId,
            "name": name!,
            "comment": self.commentTextField.text!,
            "date": FieldValue.serverTimestamp(),
        ] as [String : Any]
        commentRef.setData(commentDic)
        print("これ！", commentDic)
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "投稿しました")
        // 投稿処理が完了したので先頭画面に戻る
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        
        }
    }
        
    func validate() -> (Int) {
        var validComment:Int = 0
            
        if commentTextField.text!.isEmpty  {
            validComment = 1
        } else if commentTextField.text!.count > 20 {
            validComment = 2
        }
        return validComment
            
    }
    //viewWillDisappear(_:)メソッドは遷移する際に、画面が非表示になるとき呼ばれるメソッド
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

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
