//
//  CalendarViewController.swift
//  Clock_ver_01
//
//  Created by 민경준 on 2017. 10. 1..
//  Copyright © 2017년 민경준. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var SumOfDay: UILabel!
    @IBOutlet weak var CalendarTableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    var wholeRecord : EntireDataSet?
    var Record : RecordOfADay?
    
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CalendarTableView.delegate = self
        CalendarTableView.dataSource = self
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var today = Date()
        var todayString = self.formatter.string(from: today)
        self.calendar.select(self.formatter.date(from: todayString)!)
        self.calendar.accessibilityIdentifier = "calendar"
        
        if let check = loadData(){
            wholeRecord = check
            if var reCheck = wholeRecord?.Records[todayString]{
                Record = reCheck
                SumOfDay.text = setSumOfDay(record: Record!)
                CalendarTableView.reloadData()
            }else{
                SumOfDay.text = " 공부 기록 없음"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("calendar did select date \(self.formatter.string(from: date))")
        var dateString = self.formatter.string(from: date)
        
        if var check = loadData(){
            wholeRecord = check
            if var reCheck = wholeRecord?.Records[dateString]{
                Record = reCheck
                SumOfDay.text = setSumOfDay(record: Record!)
                print("  공부한 기록 있음")
                self.CalendarTableView.reloadData()
                
                
            }else{
                print("공부한 기록 없음")
                Record = nil
                self.CalendarTableView.reloadData()
                SumOfDay.text = "  공부 기록 없음"
            }
        }
        
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("cell count : " + String(describing: self.Record?.Subjects.count))

        if var ret = self.Record?.Subjects.count {
            print(ret)
            return ret
        }
        print("0 return")
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("func return cell")
        let row = self.Record?.Subjects[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectCell")
        let cellSubjectName = cell?.viewWithTag(103) as? UILabel
        let cellSubjectDuration = cell?.viewWithTag(104) as? UILabel
        
        cellSubjectName?.text = row?.Name
        let duration = (row?.Duration)!
        let hour = padZero(duration/3600)
        let mins = padZero((duration%3600)/60)
        let secs = padZero(duration % 60)
        cellSubjectDuration?.text = hour + " : " + mins + " : " + secs
        
        
        if(cell == nil){
            print("cell이 비엇음")
        }
        return cell!
    }
    
    
    func loadData() -> EntireDataSet?{
        return NSKeyedUnarchiver.unarchiveObject(withFile: EntireDataSet.ArchiveURL.path) as? EntireDataSet
    }
    
    func padZero(_ numb:Int)->String{
        let numb2 = (numb<10 ? "0" : "")+String(numb)
        return numb2
    }
    
    func setSumOfDay(record:RecordOfADay) -> String{
        var sum = 0
        for item in record.Subjects{
            sum = sum + item.Duration!
        }
        let hour = padZero(sum/3600)
        let mins = padZero((sum%3600)/60)
        let secs = padZero(sum % 60)
        let ret = "  이 날의 공부 시간 [ " + hour + " : " + mins + " : " + secs + " ]"
        return ret
    }
}
