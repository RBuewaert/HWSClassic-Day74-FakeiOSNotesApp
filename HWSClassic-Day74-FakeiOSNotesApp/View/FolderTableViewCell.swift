//
//  FolderTableViewCell.swift
//  Project21M
//
//  Created by Romain Buewaert on 05/11/2021.
//

import UIKit

final class FolderTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!

    // MARK: - Method
    func configure(folder: Folder) {
        titleLabel.text = folder.name
        numberLabel.text = "\(folder.notes.count)"
    }
}
