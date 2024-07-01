//
//  AdminCommentViewController.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 4/10/21.
//

import UIKit

class AdminCommentViewController: UIViewController, CellDelegate3 {

    @IBOutlet weak var commentTableView: UITableView!
    var comments: [String] = []
    var commentsFinal: [String] = []
    var post: Post? = nil
    func setComms(commentsNew: [String]) {
        //print("delegate")
        print(commentsNew)
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentsFinal.removeAll()
        comments = commentsNew
        commentsFinal = comments
        commentTableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.reloadData()
        getCom()
    }
    
    func getCom() {
        commentsFinal = comments
        commentTableView.reloadData()
    }
}
extension AdminCommentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentsFinal.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Comments", for: indexPath) as? CommentTableViewCell
        let comment = commentsFinal[indexPath.item]
        cell?.username.text = comment
        cell?.thePost = post
        cell?.delegate = self
        let username = comment.components(separatedBy: ": ")[0]
        return cell!
    }
}
