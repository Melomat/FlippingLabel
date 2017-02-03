//
//  ViewController.swift
//  FlippingLabelExample
//
//  Created by Matthias Mellouli on 2017-02-03.
//  Copyright © 2017 Matthias Mellouli. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var hourTensLabel: FlippingLabel!
    @IBOutlet weak var hourUnitsLabel: FlippingLabel!
    @IBOutlet weak var minuteTensLabel: FlippingLabel!
    @IBOutlet weak var minuteUnitsLabel: FlippingLabel!
    @IBOutlet weak var secondTensLabel: FlippingLabel!
    @IBOutlet weak var secondUnitsLabel: FlippingLabel!
    
    @IBOutlet weak var fullDateLabel: FlippingLabel!

    var timer: Timer!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateClock(animated: false)
        startClockTimer()
    }
    
    func updateClock(animated:Bool) {
        
        let date = Date()
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss:SS"
        let dateString: String = dateFormatter.string(from: date)
        let units: [String] = dateString.components(separatedBy: ":")
        
        dateFormatter.dateFormat = "hh:mm:ss"
        let fullDateString = dateFormatter.string(from: date)
        
        if animated == true {
            
            //HOURS
            hourTensLabel.updateWithText(units[0].substring(to: units[0].index(units[0].startIndex, offsetBy: 1)))
            hourUnitsLabel.updateWithText(units[0].substring(from: units[0].index(units[0].startIndex, offsetBy: 1)))
            
            //MINUTES
            minuteTensLabel.updateWithText(units[1].substring(to: units[0].index(units[0].startIndex, offsetBy: 1)))
            minuteUnitsLabel.updateWithText(units[1].substring(from: units[0].index(units[0].startIndex, offsetBy: 1)))
            
            //SECONDS
            secondTensLabel.updateWithText(units[2].substring(to: units[0].index(units[0].startIndex, offsetBy: 1)))
            secondUnitsLabel.updateWithText(units[2].substring(from: units[0].index(units[0].startIndex, offsetBy: 1)))
            
            fullDateLabel.updateWithText(fullDateString)
        } else {
            
            //HOURS
            hourTensLabel.text = units[0].substring(to: units[0].index(units[0].startIndex, offsetBy: 1))
            hourUnitsLabel.text = units[0].substring(from: units[0].index(units[0].startIndex, offsetBy: 1))
            
            //MINUTES
            minuteTensLabel.text = units[1].substring(to: units[0].index(units[0].startIndex, offsetBy: 1))
            minuteUnitsLabel.text = units[1].substring(from: units[0].index(units[0].startIndex, offsetBy: 1))
            
            //SECONDS
            secondTensLabel.text = units[2].substring(to: units[0].index(units[0].startIndex, offsetBy: 1))
            secondUnitsLabel.text = units[2].substring(from: units[0].index(units[0].startIndex, offsetBy: 1))
            
            fullDateLabel.text = fullDateString
            
        }
    }

    
    
    /// Gives an Date object corresponding to the next exact second (000 ms)
    /// - Returns: a Date Object
    fileprivate func nextSecondDate() -> Date {
        let date = Date()
        let calendar = Calendar(identifier: .gregorian)
        let currentComponents = calendar.dateComponents([.hour, .minute, .second], from: date)
        return calendar.date(bySettingHour: currentComponents.hour!, minute: currentComponents.minute!, second: (currentComponents.second!+1) % 60, of: date)!
    }
    
    
    
    
}


// MARK: - timer
extension ViewController {
    
    fileprivate func startClockTimer() {
        
        // We will start the timer half a second after the next 'exact second'
        // to avoir precision problem for the next clock update (for example getting
        // the text one millisecond too early could show a wrong clock time
        
        let fireDate = nextSecondDate()
        var fireDateTimeInterval = fireDate.timeIntervalSince1970
        fireDateTimeInterval += 0.5
        
        timer = Timer.scheduledTimer(timeInterval: 1.00, target: self, selector: #selector(self.handleTimerTick), userInfo: nil, repeats: true)
    }
    
    @objc fileprivate func handleTimerTick() {
        self.updateClock(animated: true)
    }
}
