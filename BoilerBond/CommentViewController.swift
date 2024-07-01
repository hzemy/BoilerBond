//
//  CommentViewController.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 4/9/21.
//

import UIKit
protocol CellDelegate3 {
    func setComms(commentsNew: [String])
}
class CommentViewController: UIViewController, CellDelegate3 {
    
    func setComms(commentsNew: [String]) {
        //print("delegate")
        print(commentsNew)
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        commentsFinal.removeAll()
        comments = commentsNew
        commentsFinal = comments
        commentsTableView.reloadData()
    }
    @IBOutlet weak var commentsTableView: UITableView!
    var currentUser: User? = nil
    var comments: [String] = []
    var commentsFinal: [String] = []
    var post: Post? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        User.getCurrentUser(completion: getUser)
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        commentsTableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        commentsFinal.removeAll()
        post?.getComments(addComment: addCom)
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        commentsTableView.reloadData()
    }
    func getUser(currentUser: User) {
        self.currentUser = currentUser
        commentsFinal = comments
       // print("getUser")
        //print(commentsFinal)
        commentsTableView.reloadData()
        //post!.getComments(addComment: addComments)
    }
    func addCom(comments: [String]) {
        commentsFinal.removeAll()
        for c in comments {
            commentsFinal.append(c)
        }
        commentsTableView.reloadData()
    }
}
extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
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
        print(currentUser?.email != username)
        if (currentUser?.email != username) {
            cell?.deleteButton.isHidden = true
        }
        
        return cell!
    }
}
