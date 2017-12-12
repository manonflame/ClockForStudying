//
//  ClockViewController.swift
//  Clock_ver_01
//
//  Created by 민경준 on 2017. 10. 1..
//  Copyright © 2017년 민경준. All rights reserved.
//

import UIKit
import CoreMedia

class ClockViewController: UIViewController {
    
    var timer : Timer!
    var tic = true
    @IBOutlet weak var YEAR: UILabel!
    @IBOutlet weak var MONTH: UILabel!
    @IBOutlet weak var DAY: UILabel!
    @IBOutlet weak var WEEK: UILabel!
    @IBOutlet weak var NOON: UILabel!
    @IBOutlet weak var HHMM: UILabel!
    @IBOutlet weak var TicTor: UILabel!
    @IBOutlet weak var MMHH: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        updateClock()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ClockViewController.updateClock), userInfo: nil, repeats: true)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear")
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    
    @objc func updateClock(){
        let date = Date()
        let calendar = Calendar.current
        let requestedComponents: NSCalendar.Unit = [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.weekday ,NSCalendar.Unit.hour, NSCalendar.Unit.minute]
        let components = (calendar as NSCalendar).components(requestedComponents, from: date)
        let year = components.year
        let month = components.month
        let day = components.day
        let weekday = components.weekday
        var hour = components.hour
        let minutes = components.minute
        if hour! > 12{
            hour = hour! - 12
            NOON.text = "PM"
        }
        else{
            NOON.text = "AM"
        }
        if(tic){
            HHMM.text = padZero(hour!)
            MMHH.text = padZero(minutes!)
            tic = false
            TicTor.text = " "
        }else{
            HHMM.text = padZero(hour!)
            MMHH.text = padZero(minutes!)
            tic = true
            TicTor.text = ":"
        }
        YEAR.text = String(describing: year!) + " "
        MONTH.text = String(describing: month!)
        DAY.text = String(describing: day!)
        WEEK.text = " "+returnStr(num: weekday!)
    }
    
    
    func padZero(_ numb:Int)->String{
        let numb2 = (numb<10 ? "0" : "")+String(numb)
        return numb2
    }
    
    
    func returnStr(num : Int) -> String{
        switch num {
        case 1:
            return "SUN"
        case 2:
            return "MON"
        case 3:
            return "TUE"
        case 4:
            return "WED"
        case 5:
            return "THU"
        case 6:
            return "FRI"
        case 7:
            return "SAT"
        default:
            return "ERROR"
        }
    }

    
}
