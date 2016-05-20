//
//  SettingsKeys.swift
//  Breakout
//
//  Created by Noah Safian on 5/20/16.
//  Copyright © 2016 Noah Safian. All rights reserved.
//

import Foundation
import UIKit

struct SettingsKeys {
    static let numRowsKey = "numRows"
    static let numColsKey = "numCols"
    static let beginnerModeKey = "beginnerMode"
    static let brickColorKey = "brickColor"
    static let tapStrengthKey = "tapStrength"
}

extension NSUserDefaults {
    func colorForKey(key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = dataForKey(key) {
            color = NSKeyedUnarchiver.unarchiveObjectWithData(colorData) as? UIColor
        }
        return color
    }
    
    func setColor(color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            colorData = NSKeyedArchiver.archivedDataWithRootObject(color)
        }
        setObject(colorData, forKey: key)
    }
}