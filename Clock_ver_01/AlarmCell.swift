//
//  AlarmCell.swift
//  Clock_ver_01
//
//  Created by 민경준 on 2017. 10. 1..
//  Copyright © 2017년 민경준. All rights reserved.
//

import UIKit


class AlarmCell: NSObject, NSCoding{
    var AlarmName : String = ""
    var AlarmDuHour : String = ""
    var AlarmDuMin : String = ""
    var AlarmDuSec : String = ""
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("myClock_Alarm")
    
    init(name: String, hour: String, min: String, sec: String){
        AlarmName = name
        AlarmDuHour = hour
        AlarmDuMin = min
        AlarmDuSec = sec
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(AlarmName, forKey: "AlarmName")
        aCoder.encode(AlarmDuHour, forKey: "AlarmDuHour")
        aCoder.encode(AlarmDuMin, forKey: "AlarmDuMin")
        aCoder.encode(AlarmDuSec, forKey: "AlarmDuSec")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "AlarmName") as? String
        let hour = aDecoder.decodeObject(forKey: "AlarmDuHour") as? String
        let min = aDecoder.decodeObject(forKey: "AlarmDuMin") as? String
        let sec = aDecoder.decodeObject(forKey: "AlarmDuSec") as? String
        self.init(name: name!, hour: hour!, min: min!, sec: sec!)
    }
    
    
}

