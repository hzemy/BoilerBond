//
//  EnrolledCoursesTableViewCell.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 3/8/21.
//

import UIKit

class EnrolledCoursesTableViewCell: UITableViewCell {

    @IBOutlet weak var leave: UIButton!
    @IBOutlet weak var courseName: UILabel!
    
    var delegate: ClassCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func leaveClicked(_ sender: Any) {
        delegate?.removeClass(className: courseName.text!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
