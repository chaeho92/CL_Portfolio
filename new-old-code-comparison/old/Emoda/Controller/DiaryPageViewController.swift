//
//  DiaryPageViewController.swift
//  Emoda
//
//  Created by Piano on 2020/03/22.
//  Copyright © 2020 Piano. All rights reserved.
//

import UIKit

// 단지 앞선 화면에서 넘어온 값을 표시만 해주고 아무 기능도 없어 Seq, Email은 추후 메시지 기능 구현 시 사용할거야 하지만 시간 문제로 메시지는 안되겠다
class DiaryPageViewController: UIViewController {

    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var textViewContents: UITextView!
    @IBOutlet weak var imageViewEmotion: UIImageView!
    
    var diary_Seq = 0
    var userInfo_Email = ""
    var diary_Emotion = 0
    var diary_Title = ""
    var diary_Contents = ""
    var diary_Date = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelDate.text = diary_Date
        labelTitle.text = diary_Title
        textViewContents.text = diary_Contents
        imageViewEmotion.image = UIImage(named: imageFileName[diary_Emotion])
        
        // 뷰 둥글게
        textViewContents.layer.cornerRadius = 4
    
        // Do any additional setup after loading the view.
    }

    func receivedItems(_ diary_Seq: Int, _ userInfo_Email: String, _ diary_Emotion: Int, _ diary_Title: String, _ diary_Contents: String, _ diary_Date: String) {
        
        self.diary_Seq = diary_Seq
        self.userInfo_Email = userInfo_Email
        self.diary_Emotion = diary_Emotion
        self.diary_Title = diary_Title
        self.diary_Contents = diary_Contents
        self.diary_Date = diary_Date
        
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
