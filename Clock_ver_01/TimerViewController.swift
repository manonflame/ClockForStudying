//
//  TimerViewController.swift
//  Clock_ver_01
//
//  Created by 민경준 on 2017. 12. 1..
//  Copyright © 2017년 민경준. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController{
 
    
    var isPlaying = false
    var canStart = true
    
    var timer = Timer()
    var counter = 0
    
    var seconds = 0
    var minutes = 0
    var hours = 0
    
    

    
    var nowStudyingSubject : Subject?
    var Record : RecordOfADay?
    var wholeRecord : EntireDataSet?
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("myClock")
    
    
    
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var noonLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var SubjectLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minuteLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var startButtonUI: UIButton!
    @IBOutlet weak var quitButtonUI: UIButton!
    
    @IBAction func quitButton(_ sender: Any) {
        timer.invalidate()
        var message = "ㅋ끈기보소"
        if counter > 3600 {
            message = "꼴랑 1시간함"
        }else if counter > 7200{
            message = "올ㅋ"
        }else if counter > 10800{
            message = "수고하셨습니다."
        }
        
        let isStopAlert = UIAlertController(title: "공부 그만", message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "더 할거임🔥", style: .cancel){
            (_) in
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerViewController.updateTimer), userInfo: nil, repeats: true)
            return
        }
        let stop = UIAlertAction(title:"수고했어여👍🏻", style:.default){
            (_) in
            if self.canStart{
                return
            }
            self.nowStudyingSubject?.Duration = (self.nowStudyingSubject?.Duration)! + self.counter
            self.check()
            self.saveData()
            self.counter = 0
            self.isPlaying = false
            self.hourLabel.text = "00"
            self.minuteLabel.text = "00"
            self.secondLabel.text = "00"
            self.isPlaying = false
            self.startButtonUI.setTitle("시작", for: .normal)
            self.SubjectLabel.text = "-"
            self.quitButtonUI.isEnabled = false
            self.startButtonUI.setTitle("시작", for: .normal)
            self.counter = 0
            UIApplication.shared.isIdleTimerDisabled = false
        }
        isStopAlert.addAction(cancel)
        isStopAlert.addAction(stop)
        
        self.present(isStopAlert, animated: false)
    }
    
    
    @IBAction func startButton(_ sender: Any) {
        
        if(isPlaying){
            print("check3")
            return
        }
        if counter > 0 {
            print("check2")
            isPlaying = true
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerViewController.updateTimer), userInfo: nil, repeats: true)
            return
        }
        print("check1")
        let alert = UIAlertController(title: "공부 시작✍🏻", message: "공부할 과목을 입력하세요", preferredStyle: .alert)
        
        let cancel  = UIAlertAction(title: "취소", style: .cancel){
            (_) in
            print("취소")
            return
        }
        let start = UIAlertAction(title: "시작", style: .default){
            (_) in
            self.canStart = false
            //입력된 텍스트를 레이블에 입력
            if let tf = alert.textFields?[0]{
                self.SubjectLabel.text = tf.text!
            }
            
            self.quitButtonUI.isEnabled = true
            if var check = self.Record!.searchingRecord(SbjName: self.SubjectLabel.text!){
                self.nowStudyingSubject = check
                print("이미 공부한 과목  : "+"\((self.nowStudyingSubject?.Name)!)")
            }else{
                print("처음 공부하는 과목")
                self.nowStudyingSubject = Subject(name: "", duration: 0)
                self.nowStudyingSubject?.Name = self.SubjectLabel.text!
                self.Record?.Subjects.append(self.nowStudyingSubject!)
                print(self.Record?.Subjects.count)
            }
            
            //그리고 시작
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerViewController.updateTimer), userInfo: nil, repeats: true)
            self.isPlaying = true
            
            UIApplication.shared.isIdleTimerDisabled = true
        }
        alert.addTextField(configurationHandler: { (tf) in
            tf.placeholder = "과목명"
        })
        alert.addAction(cancel)
        alert.addAction(start)
        
        
        self.present(alert, animated: false)
        
        
    }
    
    @IBAction func pauseButton(_ sender: Any) {
        if(!isPlaying){
            return
        }
        timer.invalidate()
        isPlaying = false
        startButtonUI.setTitle("재개", for: .normal)
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var date = Date()
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        var dateString = dateFormatter.string(from: date)
        
        self.quitButtonUI.isEnabled = false
        
        
        if var check = loadData(){
            wholeRecord = check
            if var reCheck = wholeRecord?.Records[dateString]{
                Record = reCheck
                print("오늘 공부한적 있음" + "\(Record?.Subjects.count)")
            }
            else{
                print("공부 오늘 처음함" + dateString)
                Record = RecordOfADay(subjects: [Subject](), date:dateString)
                self.wholeRecord?.Records[dateString] = Record
            }
        }
        else{
            //디비가 아예 없으므로 만들고 저장
            print("앱을 아예 처음 킴")
            Record = RecordOfADay(subjects: [Subject](), date:dateString)
            var dic = [String:RecordOfADay]()
            dic[Record!.Date] = Record
            wholeRecord = EntireDataSet(dic: dic)
        }
        setUpperLabels()        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func updateTimer() {
        setUpperLabels()
        
        counter = counter + 1
        seconds = counter % 60
        minutes = (counter % 3600) / 60
        hours = counter/3600
        
        hourLabel.text = padZero(hours)
        minuteLabel.text = padZero(minutes)
        secondLabel.text = padZero(seconds)
    }
    
    func padZero(_ numb:Int)->String{
        let numb2 = (numb<10 ? "0" : "")+String(numb)
        return numb2
    }
    
    func saveData(){
        print("saveData()시작")
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(wholeRecord, toFile: EntireDataSet.ArchiveURL.path)
        if isSuccessfulSave {
            print("save Successfully")
        } else {
            print("saving Failed")
        }
    }
    
    func loadData() -> EntireDataSet?{
        return NSKeyedUnarchiver.unarchiveObject(withFile: EntireDataSet.ArchiveURL.path) as? EntireDataSet
    }
    
    
    func check(){
        var date = Date()
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        var dateString = dateFormatter.string(from: date)
        
//        for var item in (self.wholeRecord?.Records[dateString]?.Subjects)!{
//            print("forcheck(): " + "\(item.Name)")
//            print("forcheck(): " + "\(item.Duration)")
//        }
    }
    
    func setUpperLabels(){
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
            noonLabel.text = "PM"
        }
        else{
            noonLabel.text = "AM"
        }
        dateLabel.text = String(describing: year!)+" - "+String(describing: month!)+" - "+String(describing: day!)
        timeLabel.text = padZero(hour!) + ":" + padZero(minutes!)
        dayLabel.text = returnStr(num: weekday!)
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
