//
//  Extension.swift
//  Project21M
//
//  Created by Romain Buewaert on 05/11/2021.
//

import UIKit

extension UITextField {
    enum ImageSide {
        case left, right
    }

    func setupImage(image: UIImage, imageSide: ImageSide) {
        switch imageSide {
        case .left:
            leftViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.image = image
            leftView = imageView
        case .right:
            rightViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.image = image
            rightView = imageView
        }
    }
}
