//
//  EnrolledCoursesViewController.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 3/8/21.
//

import UIKit


protocol ClassCellDelegate {
    func removeClass(className: String)
}

class EnrolledCoursesViewController: UIViewController, ClassCellDelegate {
 
    @IBOutlet weak var enrolledCoursesTableView: UITableView!
    var currentUser: User? = nil
    var courses: [Course] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        courses.removeAll()
        enrolledCoursesTableView.delegate = self
        enrolledCoursesTableView.dataSource = self
        User.getCurrentUser(completion: getUser)
    }
    
    func getUser(currentUser: User) {
        self.currentUser = currentUser
        currentUser.getEnrolledCourses(addCourse: addCourse) // populates the courses array
    }
    func addCourse(course: Course) {
        courses.append(course)
        enrolledCoursesTableView.reloadData()
    }

    
    func removeClass(className: String) {
        currentUser?.removeClass(className: className)
        viewDidLoad()
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
extension EnrolledCoursesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Courses", for: indexPath) as? EnrolledCoursesTableViewCell
        let course = courses[indexPath.item]
        cell?.delegate = self
        cell?.courseName?.text = course.title
        return cell!
    }

}
