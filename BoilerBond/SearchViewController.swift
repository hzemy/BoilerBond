//
//  SearchViewController.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 2/21/21.
//

import UIKit

protocol SearchCellDelegate {
    func enrollClass(className: String)
}



class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIAdaptivePresentationControllerDelegate, SearchCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Course", for: indexPath) as? CourseTableViewCell
        let topic = filteredData[indexPath.row]
        cell?.delegate = self
        cell?.name.text = topic.title
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
               //print("row: \(indexPath.row)")
               //print("course: \(filteredData[indexPath.row].title)")
               name = filteredData[indexPath.row]
               self.performSegue(withIdentifier: "toPosts", sender: self)
           }
          
           override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
               if segue.identifier == "toPosts" {
                   let viewController = segue.destination as! CoursePostsViewController
                   viewController.course = name
               }
            if segue.identifier == "mySegue" {
              segue.destination.presentationController?.delegate = self;
            }
           }
    
    @IBOutlet weak var courseList: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var allCourseArray: [Course] = []
    var currentUser: User? = nil
    var name:Course? = nil
    var filteredData: [Course] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        courseList.delegate = self
        courseList.dataSource = self
        searchBar.delegate = self
        User.getCurrentUser(completion: getUser)
    }
    override func viewWillAppear(_ animated: Bool) {
        courseList.delegate = self
        courseList.dataSource = self
        searchBar.delegate = self
        User.getCurrentUser(completion: getUser)
    }
    func getUser(user: User) {
        self.currentUser = user
        currentUser!.getAllCourses(allCourses: getCourses)
        courseList.reloadData()
        
    }
    
    func enrollClass(className: String) {
        currentUser?.enrollCourse(course: className)
    }
    
    func getCourses(allCourses: [Course]) {
        self.allCourseArray = allCourses
        filteredData = allCourseArray
        courseList.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty) {
            filteredData = allCourseArray
        }
        else {
            filteredData = searchText.isEmpty ? allCourseArray : allCourseArray.filter { (item: Course) -> Bool in
                return item.title.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        }
        courseList.reloadData()
        }
    public func presentationControllerDidDismiss(
        _ presentationController: UIPresentationController)
      {
        viewWillAppear(true)
      }
}

