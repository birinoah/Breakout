//
//  SettingsViewController.swift
//  Breakout
//
//  Created by Noah Safian on 5/20/16.
//  Copyright © 2016 Noah Safian. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var pushStrengthSlider: UISlider!
    
    @IBAction func pushStrengthSliderChanged(sender: UISlider) {
        pushStrength = Double(sender.value)
        defaults.setDouble(pushStrength, forKey: SettingsKeys.tapStrengthKey)
    }
    @IBOutlet weak var pushStrengthLabel: UILabel!
    
    var pushStrength: Double {
        get {
            return Double(pushStrengthSlider.value)
        }
        set {
            
            pushStrengthLabel.text = String(format: "Tap push strength is %.2g", newValue)
            if pushStrengthSlider.value != Float(newValue) {
                pushStrengthSlider.setValue(Float(newValue), animated: true)
            }
        }
    }

    @IBOutlet weak var colsStepper: UIStepper!
    @IBAction func numColsChanged(sender: UIStepper) {
        numCols = Int(sender.value)
        defaults.setInteger(numCols, forKey: SettingsKeys.numColsKey)
    }
    
    var numCols: Int {
        get {
            return Int(colsStepper.value)
        }
        set {
            
            numColsLabel.text = "\(Int(newValue)) columns"
            if Int(colsStepper.value) != newValue {
                colsStepper.value = Double(newValue)
            }
        }
    }
    
    @IBOutlet weak var numColsLabel: UILabel!
    
    
    @IBOutlet weak var rowsStepper: UIStepper!
    @IBAction func numRowsChanged(sender: UIStepper) {
        numRows = Int(sender.value)
        defaults.setInteger(numRows, forKey: SettingsKeys.numRowsKey)
    }
    
    var numRows: Int {
        get {
            return Int(rowsStepper.value)
        }
        set {
            
            numRowsLabel.text = "\(Int(newValue)) rows"
            if Int(rowsStepper.value) != newValue {
                rowsStepper.value = Double(newValue)
            }
        }
    }
    
    @IBOutlet weak var numRowsLabel: UILabel!
    
    let colorDictionary: Dictionary<String, UIColor> = { _ in
        var dic = Dictionary<String, UIColor>()
        dic["Orange"] = UIColor.orangeColor()
        dic["Red"] = UIColor.redColor()
        dic["White"] = UIColor.whiteColor()
        dic["Blue"] = UIColor.blueColor()
        dic["Green"] = UIColor.greenColor()
        return dic
    }()
    
    @IBOutlet weak var colorControl: UISegmentedControl!
    @IBAction func brickColorChanged(sender: UISegmentedControl) {
        let title = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)!
        
        if let color = colorDictionary[title] {
            defaults.setColor(color, forKey: SettingsKeys.brickColorKey)
        }
        
    }
    
    @IBOutlet weak var beginnerSwitch: UISwitch!
    @IBAction func beginnerModeSwitchChanged(sender: UISwitch) {
        defaults.setBool(sender.on, forKey: SettingsKeys.beginnerModeKey)
    }
    
    override func viewDidLoad() {
        pushStrength = defaults.doubleForKey(SettingsKeys.tapStrengthKey)
        pushStrengthSlider.minimumValue = 0
        pushStrengthSlider.maximumValue = 1
        
        colsStepper.minimumValue = 1
        colsStepper.maximumValue = 20
        numCols = defaults.integerForKey(SettingsKeys.numColsKey)
        
        rowsStepper.minimumValue = 1
        rowsStepper.maximumValue = 6
        numRows = defaults.integerForKey(SettingsKeys.numRowsKey)
        
        if let color = defaults.colorForKey(SettingsKeys.brickColorKey) {
            let keys = (colorDictionary as NSDictionary).allKeysForObject(color) as! [String]
            let key = keys[0]
            for i in 0..<colorControl.numberOfSegments {
                if colorControl.titleForSegmentAtIndex(i) == key {
                    colorControl.selectedSegmentIndex = i
                    break
                }
            }
        }
        
        beginnerSwitch.on = defaults.boolForKey(SettingsKeys.beginnerModeKey)
    }
}
