//
//  Subject.swift
//  Clock_ver_01
//
//  Created by 민경준 on 2017. 10. 1..
//  Copyright © 2017년 민경준. All rights reserved.
//
import UIKit


class Subject: NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Name, forKey: "Name")
        aCoder.encode(Duration, forKey: "Duration")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        var name = aDecoder.decodeObject(forKey: "Name") as? String
        var duration = aDecoder.decodeObject(forKey: "Duration") as? Int
        self.init(name: name, duration: duration)
    }
    
    init?(name: String?, duration: Int?){
        self.Name = name
        self.Duration = duration
    }
    
    var Name:String?
    var Duration:Int?
}

class RecordOfADay: NSObject, NSCoding{
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Subjects, forKey: "Subjects")
        aCoder.encode(Date, forKey: "Date")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        var subjects = aDecoder.decodeObject(forKey: "Subjects") as? [Subject]
        var date = aDecoder.decodeObject(forKey: "Date") as? String
        self.init(subjects: subjects!, date: date!)
    }
    
    var Subjects:[Subject]
    var Date:String=""
    
    
    init(subjects: [Subject], date:String){
        self.Subjects = subjects
        self.Date = date
    }
    
    func searchingRecord(SbjName: String) -> Subject?{
        for item in Subjects{
            if item.Name == SbjName{
                return item
            }
        }
        return nil
    }
}



class EntireDataSet: NSObject, NSCoding {
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("myClock_Timer")
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Records, forKey: "Records")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let dicLoaded = aDecoder.decodeObject(forKey: "Records") as? [String:RecordOfADay] else {
            print("decoding failed")
            return nil
        }
        
        self.init(dic: dicLoaded)
    }
    
    init(dic: [String:RecordOfADay]){
        Records = dic
    }
    var Records = [String:RecordOfADay]()
}











