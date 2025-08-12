//
//  SQLiteForMainPage.swift
//  Emoda
//
//  Created by Piano on 2020/03/18.
//  Copyright © 2020 Piano. All rights reserved.
//

import Foundation
import SQLite3 // ******

class SQLiteForMainPage{
    
    var emodaList = [DBForMainPage]()
    var userInfo = [DBForMainPage]()
    
    var db: OpaquePointer?

    init() {
        
    }
    
    func sqlSet() {
        // SQLite 생성하기
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Emoda.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK{
            print("error opening database")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Diary (diary_Seqno INTEGER PRIMARY KEY AUTOINCREMENT, diary_Emotion INTEGER, diary_Title TEXT, diary_Contents TEXT, diary_Date TEXT, diary_Open INTEGER)", nil, nil, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS UserInfo (userInfo_Email TEXT PRIMARY KEY, userInfo_Nickname)", nil, nil, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
    }
    
    // 기존 로그인 기록이 있다면 그것을 조회하여 로그인 없이 다이어리 입장
    func userInfoSetIfExist() -> [DBForMainPage] {
        userInfo.removeAll()
        let queryString = "SELECT userInfo_Email, userInfo_Nickname FROM UserInfo"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        while (sqlite3_step(stmt) == SQLITE_ROW){
            let userInfo_Email = String(cString: sqlite3_column_text(stmt, 0))
            let userInfo_Nickname = String(cString: sqlite3_column_text(stmt, 1))
            userInfo.append(DBForMainPage(userInfo_Email: userInfo_Email, userInfo_Nickname: userInfo_Nickname))
        }
        return userInfo
    
    }
    
    func readAction() {
      
        emodaList.removeAll()
        let queryString = "SELECT * FROM Diary"
        var stmt: OpaquePointer?

        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return
        }

        while(sqlite3_step(stmt) == SQLITE_ROW){
            let diary_Seqno = sqlite3_column_int(stmt, 0)
            let diary_Emotion = sqlite3_column_int(stmt, 1)
            let diary_Title = String(cString: sqlite3_column_text(stmt, 2))
            let diary_Contents = String(cString: sqlite3_column_text(stmt, 3))
            let diary_Date = String(cString: sqlite3_column_text(stmt, 4))
            let diary_Open = sqlite3_column_int(stmt, 5)

            emodaList.append(DBForMainPage(diary_Seqno: Int(diary_Seqno), diary_Emotion: Int(diary_Emotion), diary_Title: String(describing: diary_Title), diary_Contents: String(describing: diary_Contents), diary_Date: String(describing: diary_Date), diary_Open: Int(diary_Open)))
            
        }
    }
    
}
