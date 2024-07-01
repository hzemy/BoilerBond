//
//  CourseTableViewCell.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 2/21/21.
//

import UIKit

class CourseTableViewCell: UITableViewCell {

    @IBOutlet weak var enroll: UIButton!
    @IBOutlet weak var name: UILabel!
    
    var delegate: SearchCellDelegate?
    var course: String? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func enrollClicked(_ sender: Any) {
        delegate?.enrollClass(className: name.text!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
