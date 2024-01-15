//
//  HomeViewController.swift
//  Instagram
//
//  Created by A I on 2023/11/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    //各投稿データに対するコメントデータを格納する配列（postId, name:コメント; name:コメント; name:コメント）
    //var eachCommentArray: [String] = []
    //MyPageViewから来た時
    //var documentId = ""
    //documentIdに何か入った時に実施
    var documentId: String = "" { //ストアドプロパティ（非Optionalなら初期値が必要）
        didSet {
            for i in 0 ..< self.postArray.count {
                if self.postArray[i].id == self.documentId {
                    print("あああ", self.postArray[i].id)
                    DispatchQueue.main.async {
                       let indexPath = IndexPath(row: i, section: 0)
                       self.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: false)
                   }
                }
            }
        }
    }
    
    // Firestoreのリスナー
    var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self

        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        // ログイン済みか確認
        if Auth.auth().currentUser != nil {
            // listenerを登録して投稿データの更新を監視する
            let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
            //Postデータが更新されたのをトリガーとしてクロージャが呼び出される。監視するのがリスナーの役割。
            listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                self.postArray = querySnapshot!.documents.map { document in
                    let postData = PostData(document: document)
                    print("DEBUG_PRINT: \(postData)")
                    return postData
                }
                // TableViewの表示を更新する
                self.tableView.reloadData()
                
                //MyPageViewControllerから来た場合、選択されたドキュメントIDの投稿までスクロール表示
                /*
                for i in 0 ..< self.postArray.count {
                    if self.postArray[i].id == self.documentId {
                        print("あああ", self.postArray[i].id)
                        DispatchQueue.main.async {
                           let indexPath = IndexPath(row: i, section: 0)
                           self.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: false)
                       }
                    }
                }
                 */
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        // listenerを削除して監視を停止する
        listener?.remove()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(postArray.count)
        return postArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        //cell.setPostData(postArray[indexPath.row], commentArray[indexPath.row])
        //cell.setCommentData(commentArray[indexPath.row])
        //print("おお", commentArray[indexPath.row])
        
        // セル内のボタンのアクションをソースコードで設定する
        //本来addTarget, handleButtonなどはここでやるべきではない。cellの内容はcell内ですべき。何が押されたよ、というきっかけが知りたいだけなので。。
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        cell.commentButton.addTarget(self, action:#selector(bubbleButton(_:forEvent:)), for: .touchUpInside)
        //クロージャの定義。PostTableViewCellで宣言されているonCaptionChangedクロージャをここで定義する。
        //allCaptionButtonやallCommentButton実行時に、onCaptionChangedクロージャを実行する。
        //changedCellには押したセルのインスタンス
        cell.onCaptionChanged = { changedCell in
            guard let reloadIndexPath = self.tableView.indexPath(for: changedCell) else {
                return
            }
            //フラグを更新する（★）
            self.postArray[indexPath.row].isCaptionOpened = true
            //tableViewのうち更新したcellのみリロードする
            self.tableView.reloadRows(at: [reloadIndexPath], with: .none)
            
        }
        //changedCellには押したセルのインスタンス
        cell.onCommentChanged = { changedCell in
            guard let reloadIndexPath = self.tableView.indexPath(for: changedCell) else {
                return
            }
            //フラグを更新する（★）
            self.postArray[indexPath.row].isCommentOpened = true
            //tableViewのうち更新したcellのみリロードする
            self.tableView.reloadRows(at: [reloadIndexPath], with: .none)
            
        }
        //cell.allcaptionPreviewButton.addTarget(self, action:#selector(allCaptionButton(_:forEvent:)), for: .touchUpInside)
        //cell.allCommentPreviewButton.addTarget(self, action:#selector(allCommentButton(_:forEvent:)), for: .touchUpInside)

        return cell
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")

        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]

        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }

    var postData:PostData!
    
    @objc func bubbleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("コメントボタンが押されました")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        postData = postArray[indexPath!.row]

        //下から子Viewを出す。
        performSegue(withIdentifier: "commentSegue", sender: nil)
    }

    //segueで画面遷移する時に呼ばれる。segueはキックされている。performSegueでどのsegueをキックするかを指定
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //＋またはセルを押した場合。performSegueやstoryboardでSegueを紐づけた。
        if segue.identifier == "commentSegue" {
            //segueから遷移先のViewControllerを取得する
            let commentPostViewController:CommentPostViewController = segue.destination as! CommentPostViewController
            commentPostViewController.postCommentData = postData
        } else {
            //何もない
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
