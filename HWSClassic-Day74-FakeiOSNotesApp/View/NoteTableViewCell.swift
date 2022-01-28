//
//  NoteTableViewCell.swift
//  Project21M
//
//  Created by Romain Buewaert on 05/11/2021.
//

import UIKit

final class NoteTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!

    // MARK: - Method
    func configure(note: Note) {
        titleLabel.text = note.title
        bodyLabel.text = "\(note.body)"

        let currentDate = Date.now
        let calendar = Calendar.current

        let currentDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: currentDate)
        let noteDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: note.date)

        if currentDateComponents.year == noteDateComponents.year {
            if currentDateComponents.month == noteDateComponents.month {
                if currentDateComponents.day == noteDateComponents.day {
                    guard let hour = noteDateComponents.hour else { return }
                    guard let min = noteDateComponents.minute else { return }
                    var stringHour = ""
                    var stringMin = ""
                    if hour < 10 {
                        stringHour = "0" + "\(hour)"
                    } else {
                        stringHour = "\(hour)"
                    }
                    if min < 10 {
                        stringMin = "0" + "\(min)"
                    } else {
                        stringMin = "\(min)"
                    }
                    dateLabel.text = "\(stringHour):\(stringMin)"
                } else {
                    guard let day = noteDateComponents.day else { return }
                    guard let month = noteDateComponents.month else { return }
                    var stringDay = ""
                    var stringMonth = ""
                    if day < 10 {
                        stringDay = "0" + "\(day)"
                    } else {
                        stringDay = "\(day)"
                    }
                    if month < 10 {
                        stringMonth = "0" + "\(month)"
                    } else {
                        stringMonth = "\(month)"
                    }
                    dateLabel.text = "\(stringDay)/\(stringMonth)"
                }
            } else {
                guard let day = noteDateComponents.day else { return }
                guard let month = noteDateComponents.month else { return }
                var stringDay = ""
                var stringMonth = ""
                if day < 10 {
                    stringDay = "0" + "\(day)"
                } else {
                    stringDay = "\(day)"
                }
                if month < 10 {
                    stringMonth = "0" + "\(month)"
                } else {
                    stringMonth = "\(month)"
                }
                dateLabel.text = "\(stringDay)/\(stringMonth)"
            }
        } else {
            guard let year = noteDateComponents.year else { return }
            let stringYear = "\(year)"
            dateLabel.text = stringYear
        }
    }
}
