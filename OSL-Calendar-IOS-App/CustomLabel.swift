//
//  CustomLabel.swift
//  OSL-Calendar-IOS-App
//
//  Created by Kyle Workman on 4/11/19.
//  Copyright © 2019 Kyle Workman. All rights reserved.
//

import Foundation
import UIKit

class CustomLabel: UILabel {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let margin: CGFloat = 12
        let rect = CGRect(x: 0-margin, y: 0-margin, width: self.bounds.width, height: self.bounds.height + (margin * 2))
        return rect.contains(point)
    }
    
}
