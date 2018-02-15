//
//  AlarmInfoSingleton.swift
//  Clock_ver_01
//
//  Created by 민경준 on 2018. 2. 6..
//  Copyright © 2018년 민경준. All rights reserved.
//

import Foundation

final class AlarmInfoSingleton{
    
    static var Instance : AlarmInfoSingleton = {
        return AlarmInfoSingleton()
    }()
    
    private init(){
        print("Singleton Initiate")
    }
    
    var isPlaying = false
    var isRepeat = false
    var nowIndex = 17;
    var leftCounter = 17;
    var alarms = [AlarmCell]()
    var enterBGTime : Date?
    var stopBGTime : Date?
    
    
    func setNowIndex(_ idx: Int){
        self.nowIndex = idx
    }
    
    func setLeftCounter(_ input: Int){
        self.leftCounter = input
    }
}
