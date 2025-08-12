//
//  DBForMainPage.swift
//  Emoda
//
//  Created by Piano on 2020/03/17.
//  Copyright © 2020 Piano. All rights reserved.
//

import Foundation

class DBForMainPage{
    var diary_Seqno : Int?
    var diary_Emotion : Int?
    var diary_Title : String?
    var diary_Contents : String?
    var diary_Date : String?
    var diary_Open : Int?
    
    var userInfo_Email : String?
    var userInfo_Nickname : String?
    
    init(userInfo_Email:String, userInfo_Nickname:String) {
        self.userInfo_Email = userInfo_Email
        self.userInfo_Nickname = userInfo_Nickname
    }
    
    init(diary_Seqno: Int, diary_Emotion:Int?, diary_Title:String?, diary_Contents:String?, diary_Date:String?, diary_Open:Int?) {
        
        self.diary_Seqno = diary_Seqno
        self.diary_Emotion = diary_Emotion
        self.diary_Title = diary_Title
        self.diary_Contents = diary_Contents
        self.diary_Date = diary_Date
        self.diary_Open = diary_Open
        
    }
    
}
