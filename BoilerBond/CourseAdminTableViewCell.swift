//
//  CourseAdminTableViewCell.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 4/3/21.
//

import UIKit

class CourseAdminTableViewCell: UITableViewCell {

    @IBOutlet weak var delete: UIButton!
    @IBOutlet weak var course: UILabel!
    var theCourse: Course? = nil
    var delegate: CellDelegate4?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    @IBAction func deleteClicked(_ sender: Any) {
        //delete course
        //print(theCourse?.courseId)
        theCourse?.deleteCourse(course: theCourse!.courseId)
        delegate?.update()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
