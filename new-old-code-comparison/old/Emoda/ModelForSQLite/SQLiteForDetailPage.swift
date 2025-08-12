//
//  SQLiteForDetailPage.swift
//  Emoda
//
//  Created by Piano on 2020/03/18.
//  Copyright © 2020 Piano. All rights reserved.
//

import Foundation
import SQLite3 // ******

class SQLiteForDetailPage{
    
    var db: OpaquePointer?
    
    var diary_Seqno : Int
    var diary_Emotion : Int?
    var diary_Title : String?
    var diary_Contents : String?
    var diary_Date : String?
    var diary_Open : Int?
    
    init(diary_Seqno: Int) {
        self.diary_Seqno = diary_Seqno
    }
    
    init(diary_Seqno: Int, diary_Emotion: Int, diary_Title: String, diary_Contents: String, diary_Date: String, diary_Open: Int) {
        self.diary_Seqno = diary_Seqno
        self.diary_Emotion = diary_Emotion
        self.diary_Title = diary_Title
        self.diary_Contents = diary_Contents
        self.diary_Date = diary_Date
        self.diary_Open = diary_Open
    }
    
    func sqlSet() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Emoda.sqlite")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK{
            print("error opening database")
        }
    }
    
    func updateAction() {
        var stmt: OpaquePointer?
    
        // 이것이 데이터 수정 누를 때 중복으로 들어가는 걸 막아줌
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        
        let queryString = "UPDATE Diary SET diary_Emotion = ?, diary_Title = ?, diary_Contents = ?, diary_Date = ?, diary_Open = ? where diary_Seqno = ?"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing update : \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(stmt, 1, Int32(diary_Emotion!)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding emotion : \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 2, diary_Title!, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding title : \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 3, diary_Contents!, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding contents : \(errmsg)")
            return
        }

        if sqlite3_bind_text(stmt, 4, diary_Date!, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding date : \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(stmt, 5, Int32(diary_Open!)) != SQLITE_OK{ // int
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding open : \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(stmt, 6, Int32(diary_Seqno)) != SQLITE_OK{ // int
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding seqno : \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure update emoda : \(errmsg)")
            return
        }
        
//        print("Diary Modifed Suceessfully")

    }
    
    func deleteAction() {
        var stmt: OpaquePointer?
        
        let queryString = "DELETE from Diary where diary_Seqno = \(diary_Seqno)"
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
           let errmsg = String(cString: sqlite3_errmsg(db)!)
           print("error preparing delete : \(errmsg)")
           return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE{
           let errmsg = String(cString: sqlite3_errmsg(db)!)
           print("failure delete emoda : \(errmsg)")
           return
        }
    }

}
