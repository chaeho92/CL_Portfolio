//
//  MySQLForDetailPage.swift
//  Emoda
//
//  Created by Piano on 2020/03/21.
//  Copyright © 2020 Piano. All rights reserved.
//

import Foundation

class MySQLForDetailPageModel: NSObject{
    func DeleteItems(userInfo_Email: String, diary_Date: String) -> Bool{
        var result: Bool = true
        var urlPath = "\(coreIP)diaryQuery_OpendDataDelete.jsp?userInfo_Email=\(userInfo_Email)&diary_Date=\(diary_Date)"
        
        // 한글 url encoding 2byte문자를 1byte문자로 변환
        urlPath = urlPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let url = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        let task = defaultSession.dataTask(with: url){(data, response, error) in
            if error != nil{
                print("Failed to delete data")
                result = false
            }else{
//                print("Data is inserted!")
                result = true
            }
        }
        task.resume()
        return result
    }
    
/*
    func UpdateItems(userInfo_Email: String, diary_Date: String, diary_Emotion: Int, diary_Title: String, diary_Contents: String) -> Bool{
        var result: Bool = true
        var urlPath = "\(coreIP)diaryQuery_OpendDataUpdate.jsp?userInfo_Email=\(userInfo_Email)&diary_Date=\(diary_Date)&diary_Emotion=\(diary_Emotion)&diary_Title=\(diary_Title)&diary_Contents=\(diary_Contents)"
        
        // 한글 url encoding 2byte문자를 1byte문자로 변환
        urlPath = urlPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let url = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        let task = defaultSession.dataTask(with: url){(data, response, error) in
            if error != nil{
                print("Failed to delete data")
                result = false
            }else{
//                print("Data is inserted!")
                result = true
            }
        }
        task.resume()
        return result
    }
*/
    
}
