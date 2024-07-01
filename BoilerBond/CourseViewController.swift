//
//  CourseViewController.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 4/3/21.
//

import UIKit
protocol CellDelegate4 {
    func update()
}

class CourseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchCellDelegate, UISearchBarDelegate, CellDelegate4 {
    func update() {
        viewDidLoad()
    }
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var courseTableView: UITableView!
    var allCourseArray: [Course] = []
    var name:Course? = nil
    var filteredData: [Course] = []
    func enrollClass(className: String) {
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
               //print("row: \(indexPath.row)")
               //print("course: \(filteredData[indexPath.row].title)")
               name = filteredData[indexPath.row]
               self.performSegue(withIdentifier: "toPosts", sender: self)
           }
          
           override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
               if segue.identifier == "toPosts" {
                   let viewController = segue.destination as! AdminPostViewController
                   viewController.course = name
               }
           }
   
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.filteredData.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as? CourseAdminTableViewCell
            let topic = filteredData[indexPath.row]
            cell?.course.text = topic.title
            cell?.theCourse = topic
            cell?.delegate = self
            return cell!
        }
       
        override func viewDidLoad() {
            super.viewDidLoad()
            courseTableView.delegate = self
            courseTableView.dataSource = self
            searchBar.delegate = self
            User.getAllCoursesAdmin(allCourses: getCourses)
        }
 
        override func viewWillAppear(_ animated: Bool) {
            courseTableView.delegate = self
            courseTableView.dataSource = self
            searchBar.delegate = self
            User.getAllCoursesAdmin(allCourses: getCourses)
        }

        func getCourses(allCourses: [Course]) {
            self.allCourseArray = allCourses
            filteredData = allCourseArray
            courseTableView.reloadData()
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
            courseTableView.reloadData()
            }
    }


