//
//  AddPageViewController.swift
//  Emoda
//
//  Created by Piano on 2020/03/16.
//  Copyright © 2020 Piano. All rights reserved.
//

import UIKit

class AddPageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var imageViewEmotion: UIImageView!
    @IBOutlet weak var textFieldTitle: UITextField!
    @IBOutlet weak var textViewContent: UITextView!
    @IBOutlet weak var switchShare: UISwitch!
    @IBOutlet weak var btnSave: UIButton!
    
    // DB 조회에 쓰일 전역변수 하단의 액션으로 인해 새로운 값들이 저장 됨
    var willSendEmotion = 0
    var willSendDate = selectedDate
    var willSendShare = 0
    
    let MAX_ARRAY_NUM = imageFileName.count // 화면에 표시 할 Picker
    var imageArray = [UIImage?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 초기 이미지 및 데이터 세팅
        for i in 0..<MAX_ARRAY_NUM { // Picker 리스트 생성
            let image = UIImage(named: imageFileName[i])
            imageArray.append(image)
        }
        imageViewEmotion.image = imageArray[0]
        labelDate.text = selectedDate
        
        // 버튼, 텍스트 창 디자인
        textViewContent.layer.cornerRadius = 4
        btnSave.layer.cornerRadius = 4
        
    }
    
    // 키보드 숨기기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    // 이전 화면 백
    @IBAction func btnBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 출력될 컬럼 넘버
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // 1개씩 표시
    }
    
    // 이미지 파일 갯수
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return imageFileName.count
    }
    
    // Title(파일 Name)
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        willSendEmotion = row
        return imageFileName[row]
    }
    
    // 선택된 파일명을 레이블 및 image view에 출력
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        imageViewEmotion.image = imageArray[row]
    }
    
    @IBAction func btnAddAction(_ sender: UIButton) {

        // 공백 제거 후 값 저장
        let willSendTitle = textFieldTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let willSendContent = textViewContent.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if willSendShare == 1 {
            let mysqlforaddpage = MySQLForAddPageModel()
            let result = mysqlforaddpage.insertItems(userInfo_Email: userInfo[0].userInfo_Email!, diary_Emotion: willSendEmotion, diary_Title: willSendTitle!, diary_Contents: willSendContent!, diary_Date: willSendDate)
            if result == false{
                let insertAlert = UIAlertController(title: "Notice", message: "Please check your internet connection", preferredStyle: UIAlertController.Style.alert)
                let insertAlertAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {ACTION in
                    self.willSendShare = 0
                })
                insertAlert.addAction(insertAlertAction)
                present(insertAlert, animated: true, completion: nil)
            }
        }
        
        let sqliteforaddpage = SQLiteForAddPage(diary_Emotion: willSendEmotion, diary_Title: willSendTitle!, diary_Contents: willSendContent!, diary_Date: willSendDate, diary_Open: willSendShare)
        sqliteforaddpage.sqlSet()
        sqliteforaddpage.insertAction()
  
        let resultAlert = UIAlertController(title: "Result", message: "Your data is saved well.", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {ACTION in
            self.dismiss(animated: true, completion: nil)
        })
            
        resultAlert.addAction(okAction)
        present(resultAlert, animated: true, completion: nil)
        
    }
    
    // 스위치 값 DB Query에 들어갈 값 저장
    @IBAction func diaryShareSwitch(_ sender: UISwitch) {
        if sender.isOn {
            willSendShare = 1
        }else {
            willSendShare = 0
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
