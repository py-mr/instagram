//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by A I on 2023/12/15.
//

import UIKit
import FirebaseStorageUI
import FirebaseFirestore

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var captionLabel2: UILabel!
    
    @IBOutlet weak var commentField: UILabel!
    @IBOutlet weak var commentField2: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var allcaptionPreviewButton: UIButton!
    @IBOutlet weak var allCommentPreviewButton: UIButton!
    
    var onCaptionChanged: ((_ cell: PostTableViewCell) -> Void)?
    var onCommentChanged: ((_ cell: PostTableViewCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // PostDataの内容をセルに表示
    //func setPostData(_ postData: PostData) {
    func setPostData(_ postData: PostData) {
        // 画像の表示
        postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        postImageView.sd_setImage(with: imageRef)

        // キャプションの表示
        //★postData.userIdから、profileDataのnameを取得する
        //print("aaaa", postData.userId)
        
        
        //self.allcaptionPreviewButton.isHidden = true
        
        Firestore.firestore().collection(Const.ProfileIntroductionPath).document(postData.userId).getDocument(completion: { result,error in
            if let error = error {
                print(error)
                return
            } else {
                let name = result!.data()!["name"] as! String
                //print(name)
                self.captionLabel.text = name + " : " + postData.caption.prefix(20)
                self.captionLabel2.text = name + " : " + postData.caption
                print("ccc", self.captionLabel.text!)
                print("ccc", self.captionLabel2.text!)
                self.allcaptionPreviewButton.setTitle("続きを読む", for: .normal)
                //let height = self.captionLabel.intrinsicContentSize.height
                //let height = self.lineNumber(label: self.captionLabel, text: self.captionLabel.text!)
                //let height2 = self.captionLabel2.intrinsicContentSize.height
                //let height2 = self.lineNumber(label: self.captionLabel2, text: self.captionLabel2.text!)
                let count:Int = self.captionLabel.text!.count
                let count2:Int = self.captionLabel2.text!.count
                if postData.isCaptionOpened == false {
                    if count < count2 {
                        //labelA +「続きを表示」を表示。
                        self.captionLabel.isHidden = false
                        self.captionLabel2.isHidden = true
                        self.allcaptionPreviewButton.isHidden = false
                        print("bb", postData.id, "ボタンでる")
                    } else {
                        //labelAのみ表示。
                        self.captionLabel.isHidden = false
                        self.captionLabel2.isHidden = true
                        self.allcaptionPreviewButton.isHidden = true
                        print("bb", postData.id, "ボタンでない")
                    }
                } else {
                    self.captionLabel.isHidden = true
                    self.captionLabel2.isHidden = false
                    self.allcaptionPreviewButton.isHidden = true
                }
                /*
                 行数で判定する⇨標準でやり方はない。
                 ラベル二個用意。一個は二行までにしてもう一個はフリーで縦に伸びるラベル。もう一個は非表示にしておく。
                 A,Bに同じテキストを設定。A：３行以上の場合も２行までしか表示されない。AよりBが長ければ、「続きを読む」を出して、
                 「続きを読む」を押した時に、A表示、B非表示⇨A非表示、B表示。その時にセルの高さを変えないといけない。動的に。
                 今Aが空いているのかBが空いているのか状態をもっておく必要がある。
                 動的にやっても耐えられるようにする（レイアウト）
                 
                 
                 A、B、Cラベルが変わる
                 A,Cを表示⇨A（隙間）C　OR AC（隙間なし）
                 トルツメ（後者）⇨StackViewを使う。StackViewの中にABCを入れておく（Label,Buttonなんでも入れれる）。縦横どっちもOK。自動配列（個別に制約つけなくても勝手に並べたり。）してくれる。勝手につめてくれる。
                 部品間の間を決めることができる。行間１０の場合はA５０・１０・C５０⇨A５０になる。
                 トルママ（前者）
                 */
                
                /*
                if postData.caption.utf8.count >= 50 {
                    print("50バイト以上")
                    //二行以上/何文字以上のときは、２行のみ表示して、「...続きを読む」
                    //「続きを読む」ボタンを表示
                    self.allcaptionPreviewButton.isHidden = false
                    self.allcaptionPreviewButton.setTitle("続きを読む", for: .normal)
                    //キャプションは50バイトまで表示
                    let caption = String(postData.caption.prefix(50)) + "..."
                    self.captionLabel.text = name + " : \(caption)"

                } else {
                    self.captionLabel.text = name + " : \(postData.caption)"
                }
                 */
            }
        })
        
        //名前でなくユーザIDを表示
        //self.captionLabel.text = "\(postData.userId) : \(postData.caption)"

        // 日時の表示
        self.dateLabel.text = postData.date

        // いいね数の表示
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"

        // いいねボタンの表示
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        
        //コメントの表示
        self.commentField.text = postData.comments.joined(separator: ",").replacingOccurrences(of: ",", with: "\n")
        self.commentField2.text = postData.comments.joined(separator: ",").replacingOccurrences(of: ",", with: "\n")
        let title = "コメント" + "\(postData.comments.count)" + "件を全て表示"
        allCommentPreviewButton.setTitle(title , for: .normal)
        
        if postData.isCommentOpened == false {
            if postData.comments.count <= 1 {
                self.commentField.isHidden = false
                self.commentField2.isHidden = true
                allCommentPreviewButton.isHidden = true
            } else {
                //のときは、コメントを表示せず「コメントX件を全て表示」のボタンを表示させる
                self.commentField.isHidden = true
                self.commentField2.isHidden = true
                allCommentPreviewButton.isHidden = false
            }
        } else {
            self.commentField.isHidden = true
            self.commentField2.isHidden = false
            allCommentPreviewButton.isHidden = true
        }
        /*
        //コメントの表示
        for m in commentArray {
            if postData.id == m.postId {
                self.commentField.text = "\(m.name) : \(m.comment)"
            }
        }
         */
         
    }
    
    @IBAction func allCaptionButton(_ sender: Any) {
        //labelAと「続きを表示」を削除。
        //labelBを表示。
        self.captionLabel.isHidden = true
        self.captionLabel2.isHidden = false
        self.allcaptionPreviewButton.isHidden = true
        //クロージャを実行
        onCaptionChanged?(self)
    }
    
    @IBAction func allCommentsButton(_ sender: Any) {
        self.commentField.isHidden = true
        self.commentField2.isHidden = false
        allCommentPreviewButton.isHidden = true
        onCommentChanged?(self)
    }
    /*
    func lineNumber(label: UILabel, text: String) -> Int {
        let oneLineRect = "a".boundingRect(with: label.bounds.size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: label.font!], context: nil)
        let boundingRect = text.boundingRect(with: label.bounds.size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: label.font!], context: nil)

        return Int(boundingRect.height / oneLineRect.height)
    }
     */
}
