//
//  NotificationTableViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 06/01/21.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet var notificationTitleL: UILabel!
    @IBOutlet var notificationMessageL: UILabel!
    @IBOutlet var notificationDateL: UILabel!
    
    var notification: Notification? = nil{
        didSet{
            if let notification = self.notification{
                self.notificationTitleL.text = notification.title
                self.notificationMessageL.text = notification.message
                self.notificationDateL.text = DateHelper.shared.formatISO8601(newDateFormat: "dd MMM yyyy, HH:mm", dateString: notification.createdAt, timezone: TimeZone.current)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    private func setupViews(){
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
