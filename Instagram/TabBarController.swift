//
//  TabBarController.swift
//  Instagram
//
//  Created by A I on 2023/11/25.
//

import UIKit
import FirebaseAuth // 先頭でFirebaseAuthをimportしておく

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var homeViewController: HomeViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // タブアイコンの色
        self.tabBar.tintColor = UIColor(red: 1.0, green: 0.44, blue: 0.11, alpha: 1)
        // タブバーの背景色を設定
        let appearance = UITabBarAppearance()
        appearance.backgroundColor =  UIColor(red: 0.96, green: 0.91, blue: 0.87, alpha: 1)
        self.tabBar.standardAppearance = appearance
        self.tabBar.scrollEdgeAppearance = appearance
        // UITabBarControllerDelegateプロトコルのメソッドをこのクラスで処理する。
        self.delegate = self
    }

    // タブバーのアイコンがタップされた時に呼ばれるdelegateメソッドを処理する。
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is ImageSelectViewController {
            // ImageSelectViewControllerは、タブ切り替えではなくモーダル画面遷移する
            let imageSelectViewController = storyboard!.instantiateViewController(withIdentifier: "ImageSelect")
            present(imageSelectViewController, animated: true)
            return false
        } else {
            // その他のViewControllerは通常のタブ切り替えを実施
            return true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
        // currentUserがnilならログインしていない
        if Auth.auth().currentUser == nil {
            // ログインしていないときの処理
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(loginViewController!, animated: true, completion: nil)
        }
    }
    
    func changeHomeAndScroll(to documentId: String) {

        //HomeViewControllerにdocumentIdを渡す
        //遷移先の情報の取得
        
        //これはだめ。ここを抜けるとなくなるし、別物は表示されることはない↓
        //let homeViewController = storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        //homeViewController?.documentId = documentId
        //0番目のタブの画面を取り出してそれをHomeViewControllerに型変換する
        let vc = viewControllers![0] as! HomeViewController
        //渡したいデータを移動先のViewに渡しておく
        vc.documentId = documentId
        //タブの切り替え
        selectedIndex = 0 //HomeViewControllerの表示をしている。TabBarContollerのプロパティ。
        print(documentId)
        
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
