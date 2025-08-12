//
//  MainPageViewController.swift
//  Emoda
//
//  Created by Piano on 2020/03/16.
//  Copyright © 2020 Piano. All rights reserved.
//

import UIKit
import FSCalendar

// IP ADDRESS
let coreIP = "http://localhost:8080/diary/"

// UserInfo[0] = Email, UserInfo[1] = Nickname
var userInfo = [DBForMainPage]()

// 모달 화면 이동 시 선택한 날짜 데이터 전달 목적
var selectedSeqno = 0
var selectedEmotion = 0
var selectedTitle = ""
var selectedContents = ""
var selectedDate = ""
var selectedOpen = 0
var isExist = false

// 이미지명 보관
var imageFileName = ["Angry","Complex","Happy","Normal","Shame","Sick"]

// 통계 페이지로 넘길 값
var emotionStatisticsTemp = [0]

class MainPageViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance { // 달력 라이브러리 상속
    
    @IBOutlet weak var calendar: FSCalendar!
    
    // SQLite 조회 클래스 받아오기
    let sqliteformainpage = SQLiteForMainPage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 달력 여러 개 날짜의 선택
        // calendar.allowsMultipleSelection = false
        
        // 달력 세로로 스와이프
        calendar.scrollDirection = .vertical
        
        calendar.delegate = self
        calendar.dataSource = self
        
        // SQLite 초기 테이블 설정 후 userInfo 데이터 조회
        sqliteformainpage.sqlSet()
        userInfo = sqliteformainpage.userInfoSetIfExist()
        
    }
    
    // userInfo가 조회되지 않았다면 로그인 페이지 이동
    override func viewDidAppear(_ animated: Bool) {
        if userInfo.count < 1 {
            guard let uvc = self.storyboard?.instantiateViewController(identifier: "LoginDiary")
            else{
                return
            }
            uvc.modalPresentationStyle = .fullScreen
            self.present(uvc, animated: true)
        }
    }
    
    // 오늘 날짜 이후로는 조회 불가 및 이동 불가
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date.init()
    }
    
    // 날짜 선택 시 콜백 메소드
    public func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        selectedDate = dateFormatter.string(from: date)
        
        // 날짜를 기준으로 데이터 존재하는지를 확인하고 데이터가 존재하면 보여줄 데이터 저장
        for i in 0..<sqliteformainpage.emodaList.count{
            if sqliteformainpage.emodaList[i].diary_Date == selectedDate {
                isExist = true
                selectedSeqno = sqliteformainpage.emodaList[i].diary_Seqno!
                selectedEmotion = sqliteformainpage.emodaList[i].diary_Emotion!
                selectedTitle = sqliteformainpage.emodaList[i].diary_Title!
                selectedContents = sqliteformainpage.emodaList[i].diary_Contents!
                selectedDate = sqliteformainpage.emodaList[i].diary_Date!
                selectedOpen = sqliteformainpage.emodaList[i].diary_Open!
            }
        }
        
        // 화면 이동 구분 기능
        movePages(isExist: isExist)
        isExist = false
        
    }
    
    // StoryBoard를 통해 두번째 화면의 StoryBoard ID 참조 뷰 컨트롤러를 콜
    func movePages(isExist: Bool) {
        
        var tempIdentifier = ""
        
        if isExist {
            tempIdentifier = "detailPage"
        }else {
            tempIdentifier = "addPage"
        }
        
        guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: tempIdentifier) else{
            return
        }
        
        // 화면 전환 애니메이션을 설정
        uvc.modalPresentationStyle = .fullScreen

        // 인자값으로 다음 뷰 컨트롤러를 넣고 present 메소드를 호출
        self.present(uvc, animated: true)
        
    }
    
    func readValues(){
        // 조회 후 화면 다시 불러오기
        sqliteformainpage.readAction()
        self.calendar.reloadData()
        statisticsOfEmotion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedSeqno = 0
        selectedEmotion = 0
        selectedTitle = ""
        selectedContents = ""
        selectedDate = ""
        selectedOpen = 0
        
        // userInfo, diary Data 재 조회
        sqliteformainpage.sqlSet()
        userInfo = sqliteformainpage.userInfoSetIfExist()
        readValues()
    }
    
    // 달력 생성 시 이미지 설정
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let convertedDate = dateFormatter.string(from: date)
        
        /*
         Calendar libs가 출력하려는 날짜를 찍기 위해 반복하며 매번 이 함수로 들어올 때
         emodaList(DB 조회된 배열 값의) 크기만큼 출력하려는 날짜와 비교 후 일치하는 날의 감정을 별도의 변수에 반환
        */
        for i in 0..<sqliteformainpage.emodaList.count{
            if sqliteformainpage.emodaList[i].diary_Date == convertedDate {
                let emotionReturn = sqliteformainpage.emodaList[i].diary_Emotion!
                return UIImage(named: "\(imageFileName[emotionReturn])")
            }
        }
     
        return UIImage(named: "blank.png")
    }
    
    // 이미지 출력 시 위치 보정
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, imageOffsetFor date: Date) -> CGPoint {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let convertedDate = dateFormatter.string(from: date)
   
        for i in 0..<sqliteformainpage.emodaList.count{
            if sqliteformainpage.emodaList[i].diary_Date == convertedDate {
                return CGPoint.init(x: 0, y: 22)
            }
        }
        
        return CGPoint.init(x: 0, y: 0)
    }
    
    // 통계화면 이동
    @IBAction func statisticsAction(_ sender: UIButton) {
        guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: "statisticsBoard") else{
            return
        }
        
        // 화면 전환 애니메이션을 설정
        uvc.modalTransitionStyle = .coverVertical

        // 인자값으로 다음 뷰 컨트롤러를 넣고 present 메소드를 호출
        self.present(uvc, animated: true)
    }
    
    // 조회된 데이터 중 diary_Emotion만 별도로 변수에 저장 후 통계 페이지에서 사용
    func statisticsOfEmotion() {
        emotionStatisticsTemp.removeAll()
        var emotionStatistics = [0,0,0,0,0,0]
        for i in 0..<sqliteformainpage.emodaList.count {
            switch sqliteformainpage.emodaList[i].diary_Emotion {
            case 0:
                emotionStatistics[0] += 1
                break
            case 1:
                emotionStatistics[1] += 1
                break
            case 2:
                emotionStatistics[2] += 1
                break
            case 3:
                emotionStatistics[3] += 1
                break
            case 4:
                emotionStatistics[4] += 1
                break
            case 5:
                emotionStatistics[5] += 1
                break
            default:
                break
            }
        }
        emotionStatisticsTemp = emotionStatistics
    }
    
}


