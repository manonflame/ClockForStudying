//
//  AppDelegate.swift
//  Clock_ver_01
//
//  Created by 민경준 on 2017. 10. 1..
//  Copyright © 2017년 민경준. All rights reserved.
//

import UIKit
import os.log
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
µ
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {µ
        // Override point for customization after application launch.
        print("didFinishLaunchingWithOptions")
        sleep(2)
        let center = UNUserNotificationCenter.current()
        
        let options: UNAuthorizationOptions = [.alert, .sound]
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Notification denied")
            }
        }
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
            
        if AlarmInfoSingleton.Instance.isPlaying {
            
            //센터 객체 생성
            let center = UNUserNotificationCenter.current()
            
            //반응 액션 추가 및 아이디 부여
            let continueAction = UNNotificationAction(identifier: "ContinueAction", title: "알람 계속", options: [])
            let stopAction = UNNotificationAction(identifier: "StopAction", title: "알람 중지", options: [.destructive])
            
            //반응 액션의 집합인 카테고리 생성 및 아이디 부여
            let category = UNNotificationCategory(identifier: "AlarmCategory", actions: [continueAction,stopAction], intentIdentifiers: [], options: [])
            
            //알림 센터에 반응할 카테고리를 저장
            center.setNotificationCategories([category])
            
            var id = "AlarmID : "
            var i = 0
            var leftSecond = 0.0;
            for idx in AlarmInfoSingleton.Instance.nowIndex ..< AlarmInfoSingleton.Instance.alarms.count{
                
                var alarm = AlarmInfoSingleton.Instance.alarms[idx]
                
                //컨텐트 객체 생성
                let content = UNMutableNotificationContent()
                content.title = "시간 종료"
                content.body = alarm.AlarmName
                content.sound = UNNotificationSound.default()
                
                //컨텐트에 카테고리를 카테고리 아이디를 이용하여 연결
                content.categoryIdentifier = "AlarmCategory"
                
                if i == 0 {
                    leftSecond = Double(AlarmInfoSingleton.Instance.leftCounter)
                    
                }else{
                    leftSecond += Double(alarm.AlarmDuHour)! * 3600
                    leftSecond += Double(alarm.AlarmDuMin)! * 60
                    leftSecond += Double(alarm.AlarmDuSec)!
                }
                
                //트리거 객체 생성
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: leftSecond, repeats: false)
                
                let inputID = id + String(i)
            
                //리퀘스트 아이디와 그 내용(content객체)과 트리거를 이용하여 리퀘스트 객체 생성
                let request = UNNotificationRequest(identifier: inputID, content: content, trigger: trigger)
                
                //노티피케이션 센터에 각 리퀘스트를 추가함.
                center.add(request, withCompletionHandler: { (error) in
                    if let error = error {
                        print("error in UNUserNotificationCenter ::: \(error)")
                    }
                })
                
                i+=1
            }
            
            if AlarmInfoSingleton.Instance.isRepeat {
                
                for threeTime in 0 ..< 3 {
                    for alarm in AlarmInfoSingleton.Instance.alarms {
                        let content = UNMutableNotificationContent()
                        content.title = "시간 종료"
                        content.body = alarm.AlarmName
                        content.sound = UNNotificationSound.default()
                        
                        //컨텐트에 카테고리를 카테고리 아이디를 이용하여 연결
                        content.categoryIdentifier = "AlarmCategory"
                        
                        leftSecond += Double(alarm.AlarmDuHour)! * 3600
                        leftSecond += Double(alarm.AlarmDuMin)! * 60
                        leftSecond += Double(alarm.AlarmDuSec)!
                        
                        //트리거 객체 생성
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: leftSecond, repeats: false)
                        
                        let inputID = id + String(i)
                        
                        //리퀘스트 아이디와 그 내용(content객체)과 트리거를 이용하여 리퀘스트 객체 생성
                        let request = UNNotificationRequest(identifier: inputID, content: content, trigger: trigger)
                        
                        //노티피케이션 센터에 각 리퀘스트를 추가함.
                        center.add(request, withCompletionHandler: { (error) in
                            if let error = error {
                                print("error in UNUserNotificationCenter ::: \(error)")
                            }
                        })
                        
                        i+=1
                    }
                }
            }
        }
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    
        print("receive")
        switch response.actionIdentifier {
        case "ContinueAction":
            print("계속하기가 눌림")
            
        case "StopAction":
            print("그만하기가 눌림")
            center.removeAllPendingNotificationRequests()
            center.removeAllDeliveredNotifications()
            AlarmInfoSingleton.Instance.stopBGTime = Date()
            print("userNotificationCenter_didReceive respose: \(AlarmInfoSingleton.Instance.stopBGTime)")
            
        default:
            print("디폴트 액션")
            break
        }
    }
    

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
        
        //모든 노티피케이션 초기화
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        var storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        if let alarmVC = storyboard.instantiateViewController(withIdentifier: "AlarmViewController") as? AlarmViewController {
            print("applicationDidBecomeActive : \(alarmVC.dataList.count)")
        }
        
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UIApplication.shared.isIdleTimerDisabled = false
        print("applicationWillTerminate")
    }
}

