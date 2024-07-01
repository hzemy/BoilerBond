//
//  AdminUserViewController.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 4/3/21.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import BRYXBanner
import CodableFirebase
protocol CellDelegateDelete {
    func update()
}
class AdminUserViewController: UIViewController, SearchCellDelegate, UISearchBarDelegate, CellDelegateDelete  {
    func enrollClass(className: String) {
        
    }
    func update() {
        print("Update UI")
        viewWillAppear(true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredData.count
    }
    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var currentUser: User? = nil
    var allUsersArray: [User] = []
    var filteredData: [User] = []
    var name:User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userTableView.delegate = self
        userTableView.dataSource = self
        searchBar.delegate = self
        User.getAllUsersAdmin(allUsers:getUsers)
    }
    override func viewWillAppear(_ animated: Bool) {
        userTableView.delegate = self
        userTableView.dataSource = self
        searchBar.delegate = self
        User.getAllUsersAdmin(allUsers:getUsers)
    }
    
    func getUsers(allUsers: [User]) {
        self.allUsersArray = allUsers
        filteredData = allUsers
        for i in 0..<allUsers.count {
            let aUser = allUsersArray[i]
            //print("user: " + aUser.email)
        }
        userTableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty) {
            filteredData = allUsersArray
        }
        else {
            filteredData = searchText.isEmpty ? allUsersArray : allUsersArray.filter { (item: User) -> Bool in
                return item.email.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        }
        userTableView.reloadData()
        }
}
    
    
extension AdminUserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = filteredData[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserTableViewCell
        cell?.username.text = user.email
        cell?.delegate = self
        return cell!
    }
}
