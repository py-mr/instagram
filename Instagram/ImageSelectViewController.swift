//
//  ImageSelectViewController.swift
//  Instagram
//
//  Created by A I on 2023/11/24.
//

import UIKit
import CLImageEditor

class ImageSelectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate {
    
    var segueId = ""
    var name = ""
    var introduction = ""
    
    var parentSettingViewController: SettingViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func handleLibraryButton(_ sender: Any) {
        // ライブラリ（カメラロール）を指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    @IBAction func handleCameraButton(_ sender: Any) {
        // カメラを指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    @IBAction func handleCancelButton(_ sender: Any) {
        // 画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    // 写真を撮影/選択したときに呼ばれるメソッド（★デリゲートメソッド）
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // UIImagePickerController画面を閉じる
        picker.dismiss(animated: true, completion: nil)
        // 画像加工処理
        if info[.originalImage] != nil {
            // 撮影/選択された画像を取得する
            let image = info[.originalImage] as! UIImage
            // CLImageEditorライブラリで加工する
            print("DEBUG_PRINT: image = \(image)")
            // CLImageEditorにimageを渡して、加工画面を起動する。
            let editor = CLImageEditor(image: image)!
            editor.delegate = self
            self.present(editor, animated: true, completion: nil)
        }
    }
    //（★デリゲートメソッド）
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // UIImagePickerController画面を閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    
    // CLImageEditorで加工が終わったときに呼ばれるメソッド
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        // 投稿画面を開く（ルーティング・・・タブバーからの場合/Settingからの場合で場合分け）
        // 
        if segueId == "" {
            let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! PostViewController
            postViewController.image = image!
            editor.present(postViewController, animated: true, completion: nil)
        } else {
            //let settingViewController = self.storyboard?.instantiateViewController(withIdentifier: "Setting") as! SettingViewController
            parentSettingViewController?.name = self.name
            //parentSettingViewController?.image = image!
            parentSettingViewController?.introduction = self.introduction
            
            //editor.present(settingViewController, animated: true, completion: nil)
            //親のsettingに渡して、picker.dismiss(animated: true, completion: nil)にすればよい。コールバック用のクロージャーをたたく/デリゲートでやる。
            // CLImageEditor画面を閉じる
            editor.dismiss(animated: true) {
                //completionのタイミングでプロパティのクロージャを実行
                //画面を閉じ終わったタイミングで、settingViewControllerのcallBackメソッドが呼ばれる。
                self.parentSettingViewController?.callBack(image: image)
                //ImageSelectViewを閉じる
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // CLImageEditorの編集がキャンセルされた時に呼ばれるメソッド
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        // CLImageEditor画面を閉じる
        editor.dismiss(animated: true, completion: nil)
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
