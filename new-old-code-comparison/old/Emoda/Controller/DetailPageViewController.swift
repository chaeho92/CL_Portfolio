//
//  DetailPageViewController.swift
//  Emoda
//
//  Created by Piano on 2020/03/18.
//  Copyright © 2020 Piano. All rights reserved.
//

import UIKit
import AVFoundation // 소리 기능 import

class DetailPageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var Player: AVAudioPlayer?
    
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var imageViewEmotion: UIImageView!
    @IBOutlet weak var textFieldTitle: UITextField!
    @IBOutlet weak var textViewContents: UITextView!
    @IBOutlet weak var switchShare: UISwitch!
    @IBOutlet weak var pickerViewEmotion: UIPickerView!
    @IBOutlet weak var btnDelete: UIButton!
    
    // 데이트 피커 관련 변수
    let MAX_ARRAY_NUM = imageFileName.count // 화면에 표시 할 Picker
    var imageArray = [UIImage?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // 초기 이미지 및 데이터 세팅
        for i in 0..<MAX_ARRAY_NUM { // Picker 이미지 배열에 저장
           let image = UIImage(named: imageFileName[i])
           imageArray.append(image)
        }
        labelDate.text = selectedDate
        imageViewEmotion.image = imageArray[selectedEmotion]
        pickerViewEmotion.selectRow(selectedEmotion, inComponent: 0, animated: true) // 피커 뷰에 첫 화면을 이전에 저장한 값을 주기 위한 기능
        textFieldTitle.text = selectedTitle
        textViewContents.text = selectedContents
        if selectedOpen != 0 { switchShare.isOn = true }
        
        // 버튼 둥굴게
        textViewContents.layer.cornerRadius = 4
        btnDelete.layer.cornerRadius = 4
        
        // Do any additional setup after loading the view.
    }
    
    // 키보드 숨기기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    // Picker View의 동작에 필요한 Delegate 추가
    // 출력될 컬럼 넘버
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // 1개씩 보여줄거야
    }
    
    // 이미지 파일 갯수
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return imageFileName.count
    }
    
    // Title(파일 Name)
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        selectedEmotion = row
        return imageFileName[row]
    }
    
    // 선택된 파일명을 레이블 및 image view에 출력
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        imageViewEmotion.image = imageArray[row]
    }

    // 스위치 누를 시 해당 값을 전역변수에 저장
    @IBAction func diaryShareSwitch(_ sender: UISwitch) {
        if sender.isOn {
            selectedOpen = 1
        }else {
            selectedOpen = 0
        }
    }
    
    @IBAction func btnDelete(_ sender: UIButton) {
        
        // 얼럿 이용 실수로 삭제되는 것을 방지
        let questionAlert = UIAlertController(title: "Question", message: "Do you want to delete your data?", preferredStyle: UIAlertController.Style.alert)
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {ACTION in
            // 클래스 활용 SQLite DB 처리
            let sqlitefordetailpage = SQLiteForDetailPage(diary_Seqno: selectedSeqno)
            sqlitefordetailpage.sqlSet()
            sqlitefordetailpage.deleteAction()
            
            let mysqlfordetailpage = MySQLForDetailPageModel()
            _ = mysqlfordetailpage.DeleteItems(userInfo_Email: userInfo[0].userInfo_Email!, diary_Date: selectedDate)
            
            self.playSound()
            
            self.dismiss(animated: true, completion: nil)
        })
        let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil)
            
        questionAlert.addAction(yesAction)
        questionAlert.addAction(noAction)
        present(questionAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        
        selectedTitle = textFieldTitle.text!
        selectedContents = textViewContents.text!
        
        // 클래스 활용 SQLite DB 처리
        let sqlitefordetailpage = SQLiteForDetailPage(diary_Seqno: selectedSeqno, diary_Emotion: selectedEmotion, diary_Title: selectedTitle, diary_Contents: selectedContents, diary_Date: selectedDate, diary_Open: selectedOpen)
        sqlitefordetailpage.sqlSet()
        sqlitefordetailpage.updateAction()
        
        let mysqlfordetailpage = MySQLForDetailPageModel()
        if selectedOpen == 0 {
            _ = mysqlfordetailpage.DeleteItems(userInfo_Email: userInfo[0].userInfo_Email!, diary_Date: selectedDate)
        }else {
//            _ = mysqlfordetailpage.UpdateItems(userInfo_Email: userInfo[0].userInfo_Email!, diary_Date: selectedDate, diary_Emotion: selectedEmotion, diary_Title: selectedTitle, diary_Contents: selectedContents)
            /*
             초기에 데이터 추가 시 미리 공유가 안되었던 데이터를 공유하며 업데이트 시
             데이터가 있는지 조회하고 업데이트 또는 인서트를 하는 방법과
             데이터가 있던 없던 우선 삭제를 하고 인서트를 하는 방법 있는데
             결과적으로 비슷한 효율을 보이는 것으로 생각하여 복잡한 조회 기능을 사용하지 않기 위해
             미리 만들었던 update 기능은 주석 처리 함
             */
            _ = mysqlfordetailpage.DeleteItems(userInfo_Email: userInfo[0].userInfo_Email!, diary_Date: selectedDate)
            let mysqlforaddpage = MySQLForAddPageModel()
            _ = mysqlforaddpage.insertItems(userInfo_Email: userInfo[0].userInfo_Email!, diary_Emotion: selectedEmotion, diary_Title: selectedTitle, diary_Contents: selectedContents, diary_Date: selectedDate)
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //삭제소리
    func playSound(){
        
        let path = Bundle.main.path(forResource: "DELETE.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            Player = try AVAudioPlayer(contentsOf: url)
            Player?.play()
        } catch {
            
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
