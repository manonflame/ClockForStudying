//
//  AlarmViewController.swift
//  Clock_ver_01
//
//  Created by 민경준 on 2017. 10. 1..
//  Copyright © 2017년 민경준. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class AlarmViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var AlarmTableView: UITableView!
    //우측 지난 시간
    @IBOutlet weak var PastHour: UILabel!
    @IBOutlet weak var PastMin: UILabel!
    @IBOutlet weak var PastSec: UILabel!
    //우측 남은 시간
    @IBOutlet weak var LeftHour: UILabel!
    @IBOutlet weak var LeftMin: UILabel!
    @IBOutlet weak var LeftSec: UILabel!
    //우측 목적 시간
    @IBOutlet weak var PurposeTime: UILabel!
    //우측 입력 값들
    @IBOutlet weak var AlarmName: UITextField!
    @IBOutlet weak var InputHour: UITextField!
    @IBOutlet weak var InputMin: UITextField!
    @IBOutlet weak var InputSec: UITextField!
    //각종 버튼 UI
    @IBOutlet weak var RepeatSwitch: UISwitch!
    @IBOutlet weak var StartButton: UIButton!
    @IBOutlet weak var ResetButton: UIButton!
    //카운팅에 필요한 프로퍼티
    var AlarmTimer = Timer()
    var isPlaying = false
    var canSelect = true
    var canStart = false
    var canChange = true
    var pastCounter = 0
    var LeftCounter = 0
    var startCounter = 0
    var dataList = [AlarmCell]()
    var startIndex = 0
    var nowIndex = 0
    var isRepeat = false
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("cell return count")
        return self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("cell return func")
        let row = self.dataList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell")!
        let cellAlarmName = cell.viewWithTag(101) as? UILabel
        let cellAlarmDuration = cell.viewWithTag(102) as? UILabel
        
        cellAlarmName?.text = row.AlarmName
        cellAlarmDuration?.text = row.AlarmDuHour+":"+row.AlarmDuMin+":"+row.AlarmDuSec
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var CellMoved = self.dataList[sourceIndexPath.row]
        dataList.remove(at: sourceIndexPath.row)
        dataList.insert(CellMoved, at: destinationIndexPath.row)
        saveAlarms()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(!canSelect){
            print("진행 중이라 셀 선택에 따른 조작 불가함")
            return
        }
        print("cell selected")
        canStart = true
        let selectedCell = dataList[indexPath.row]
        //목적 시간 레이블을 바꿈
        self.PurposeTime.text = selectedCell.AlarmDuHour+" : "+selectedCell.AlarmDuMin+" : "+selectedCell.AlarmDuSec
        
        //Counter 최신화
        startCounter = Int(selectedCell.AlarmDuHour)!*3600 + Int(selectedCell.AlarmDuMin)!*60 + Int(selectedCell.AlarmDuSec)!
        LeftCounter = startCounter
        //Index최신화
        startIndex = indexPath.row
        nowIndex = startIndex
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(!canSelect){
            print("진행 중이라 삭제가 불가능함.")
        }else{
            print("진행 중이 아니라 삭제가 가능함.")
            if editingStyle == .delete {
                // Delete the row from the data source
                dataList.remove(at: indexPath.row)
                saveAlarms()
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else if editingStyle == .insert {
                // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            }
        }
    }
    
    @IBAction func startReOrder(_ sender: Any) {
        if(canChange){
            print("순서변경버튼 s")
            self.AlarmTableView.isEditing = !self.AlarmTableView.isEditing
            print("순서변경버튼 e")
        }
    }
    
    @IBAction func addAlarm(_ sender: Any) {
        print("알람 추가하기")
        var name = AlarmName.text!
        if name.count == 0{
            name = "이름 없는 알람"
        }
        var hour = InputHour.text!
        if hour.count == 0{
            hour = "00"
        }else{
            hour = padZero(Int(InputHour.text!)!)
            if hour.count >= 3{
                hour = "99"
            }
        }
        
        var min = InputMin.text!
        if min.count == 0{
            min = "00"
        }
        else{
            min = padZeroAndSixty(Int(InputMin.text!)!)
        }
        
        var sec = InputSec.text!
        if sec.count == 0{
            sec = "00"
        }
        else{
            sec = padZeroAndSixty(Int(InputSec.text!)!)
        }
        
        
        let newAlarm = AlarmCell(name: name, hour: hour, min: min, sec:sec)
        dataList.append(newAlarm)
        
        self.AlarmTableView.reloadData()
        saveAlarms()
        AlarmName.placeholder = "알람 이름을 입력하세여"
        AlarmName.text = ""
        InputHour.text = ""
        InputMin.text = ""
        InputSec.text = ""
        
        view.endEditing(true)
    }
    
    @IBAction func startAlarm(_ sender: Any) {
        if(canStart){
            if(!isPlaying){
                isPlaying = true
                canChange = false
                if(canSelect){
                    print("알람 시작하기" + "\(nowIndex)")
                    //남은 시간 셋팅
                    settingLeftTimeLabel(sec: LeftCounter)
                    //지난 시간 세팅
                    settingPastTimeLabel(sec: pastCounter)
                    //시작 색변경
                    changeCellColorPlaying(Index: nowIndex)
                    
                    canSelect = false
                    AlarmTableView.allowsSelection = false
                    StartButton.setTitle("PAUSE", for: .normal)
                    AlarmTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AlarmViewController.updateTimer), userInfo: nil, repeats: true)
                    
                    UIApplication.shared.isIdleTimerDisabled = true
                }
                else{
                    //재개 색 변경
                    changeCellColorPlaying(Index: nowIndex)
                    StartButton.setTitle("PAUSE", for: .normal)
                    AlarmTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AlarmViewController.updateTimer), userInfo: nil, repeats: true)
                }
            }
            else{
                isPlaying = false
                changeCellColorPause(Index: nowIndex)
                StartButton.setTitle("RESUME", for: .normal)
                AlarmTimer.invalidate()
            }
        }
    }
    
    @IBAction func resetAlarm(_ sender: Any) {
        if ResetButton.title(for: .normal)! == "FINISH"{
            ResetButton.setTitle("RESET", for: .normal)
        }
        AlarmTimer.invalidate()
        StartButton.isEnabled = true
        canChange = true
        pastCounter = 0
        settingPastTimeLabel(sec: 0)
        settingLeftTimeLabel(sec: startCounter)
        
        changeCellColorStop(Index: nowIndex)
        LeftCounter = startCounter
        pastCounter = 0
        nowIndex = startIndex
        changeCellColorStop(Index: nowIndex)
        
        StartButton.setTitle("START", for: .normal)
        canSelect = true
        AlarmTableView.allowsSelection = true
        if(isPlaying){
            isPlaying = false
        }
        
        let nextHour = dataList[startIndex].AlarmDuHour
        let nextMin = dataList[startIndex].AlarmDuMin
        let nextSec = dataList[startIndex].AlarmDuSec
        
        self.PurposeTime.text = String(nextHour) + " : " + String(nextMin) + " : " + String(nextSec)
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
    }
    @IBAction func OnOffRepeat(_ sender: Any) {
        isRepeat = RepeatSwitch.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AlarmTableView.delegate = self
        AlarmTableView.dataSource = self
        if let savedAlarms = LoadAlarms() {
            dataList += savedAlarms
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func updateTimer(){
        if LeftCounter <= 1{
            //알람울림
            timeOverRing()
            //현재 인덱스 색 변경
            changeCellColorStop(Index: nowIndex)
            //다음 인덱스 없으면 종료
            if(nowIndex+1 >= dataList.count){
                if(isRepeat){
                    print("다음 셀 없음 - 처음으로")
                    nowIndex = startIndex
                    let nextHour = dataList[nowIndex].AlarmDuHour
                    let nextMin = dataList[nowIndex].AlarmDuMin
                    let nextSec = dataList[nowIndex].AlarmDuSec
                    
                    self.PurposeTime.text = String(nextHour) + " : " + String(nextMin) + " : " + String(nextSec)
                    
                    LeftCounter = startCounter
                    pastCounter = 0
                    changeCellColorPlaying(Index: nowIndex)
                    settingLeftTimeLabel(sec: LeftCounter)
                    settingPastTimeLabel(sec: pastCounter)
                    return
                }
                else{
                    print("다음 셀 없음 - 반복안함")
                    AlarmTimer.invalidate()
                    pastCounter += 1
                    LeftCounter -= 1
                    settingLeftTimeLabel(sec: LeftCounter)
                    settingPastTimeLabel(sec: pastCounter)
                    StartButton.isEnabled = false
                    ResetButton.setTitle("FINISH", for: .normal)
                    return
                }
                
            }
            //다음 인덱스로
            nowIndex += 1
            print("다음 셀로")
            //남은시간 다음 셀의 시간으로 설정 ***
            var nextHour = dataList[nowIndex].AlarmDuHour
            var nextMin = dataList[nowIndex].AlarmDuMin
            var nextSec = dataList[nowIndex].AlarmDuSec
            self.PurposeTime.text = String(nextHour) + " : " + String(nextMin) + " : " + String(nextSec)

            var newCounter = 3600*Int(nextHour)! + 60*Int(nextMin)! + Int(nextSec)!
            LeftCounter = newCounter
            settingLeftTimeLabel(sec: LeftCounter)
            
            pastCounter = 0
            //지난 시간 0으로 설정
            settingPastTimeLabel(sec: pastCounter)
            //다음 인덱스 색 변경
            changeCellColorPlaying(Index: nowIndex)
        }
        else{
            pastCounter += 1
            LeftCounter -= 1
            settingLeftTimeLabel(sec: LeftCounter)
            settingPastTimeLabel(sec: pastCounter)
        }
    }
    
    func saveAlarms(){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(dataList, toFile: AlarmCell.ArchiveURL.path)
        if isSuccessfulSave {
            print("Save Alarms Successfully")
        }else{
            print("Save Alarms Failed")
        }
    }
    
    func LoadAlarms() -> [AlarmCell]?{
        print("Save Alarms")
        return NSKeyedUnarchiver.unarchiveObject(withFile: AlarmCell.ArchiveURL.path) as? [AlarmCell]
    }
    
    func padZero(_ numb:Int)->String{
        let numb2 = (numb<10 ? "0" : "")+String(numb)
        return numb2
    }
    
    func padZeroAndSixty(_ numb:Int)->String{
        var numb2 = numb
        var retStr : String
        if numb2 < 10 {
            retStr = "0"+String(numb)
        }
        else if numb2 > 59{
            retStr = "59"
        }else{
            retStr = String(numb)
        }
        return retStr
    }
    
    func settingLeftTimeLabel(sec: Int){
        LeftHour.text = padZero(sec/3600)
        LeftMin.text = padZeroAndSixty((sec%3600)/60)
        LeftSec.text = padZeroAndSixty(sec%60)
    }
    
    func settingPastTimeLabel(sec:Int){
        PastHour.text = padZero(sec/3600)
        PastMin.text = padZeroAndSixty((sec%3600)/60)
        PastSec.text = padZeroAndSixty(sec%60)
    }
    
    
    func timeOverRing(){
        print("timeOverRing()")
        AudioServicesPlaySystemSound(4095)
        AudioServicesPlaySystemSound(1005)
    }
    
    func changeCellColorPlaying(Index: Int){
        var indexPaths = AlarmTableView.indexPathsForVisibleRows
        let indexPath = indexPaths![Index]
        let Cell = AlarmTableView.cellForRow(at: indexPath)
        let alarmNameInCell = Cell?.viewWithTag(101) as? UILabel
        let alarmDurationInCell = Cell?.viewWithTag(102) as? UILabel
        alarmNameInCell?.textColor = UIColor.orange
        alarmDurationInCell?.textColor = UIColor.orange
    }
    func changeCellColorPause(Index: Int){
        var indexPaths = AlarmTableView.indexPathsForVisibleRows
        let indexPath = indexPaths![Index]
        let Cell = AlarmTableView.cellForRow(at: indexPath)
        let alarmNameInCell = Cell?.viewWithTag(101) as? UILabel
        let alarmDurationInCell = Cell?.viewWithTag(102) as? UILabel
        alarmNameInCell?.textColor = UIColor.yellow
        alarmDurationInCell?.textColor = UIColor.yellow
    }
    func changeCellColorStop(Index: Int){
        var indexPaths = AlarmTableView.indexPathsForVisibleRows
        let indexPath = indexPaths![Index]
        let Cell = AlarmTableView.cellForRow(at: indexPath)
        let alarmNameInCell = Cell?.viewWithTag(101) as? UILabel
        let alarmDurationInCell = Cell?.viewWithTag(102) as? UILabel
        alarmNameInCell?.textColor = UIColor.white
        alarmDurationInCell?.textColor = UIColor.white
    }
   
}
