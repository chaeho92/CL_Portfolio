import Foundation

protocol LocalDiaryService {
    func createDiary(_ diaryObject: DiaryObject)
    func readDiary(uuid id: String) -> DiaryObject?  // UUID 기준 조회
    func readDiariesByDay(date: Date) -> [DiaryObject]  // 일 기준 조회
    func readDiariesByMonth(date: Date) -> [DiaryObject]  // 월 기준 조회
    func readDiariesByYear(date: Date) -> [DiaryObject]  // 연 기준 조회
    func readAllDiary() -> [DiaryObject]
    func updateDiary(_ diary: Diary) -> DiaryObject?
    func deleteDiaries(diaryObjects: [DiaryObject])
    func increaseViews(diaryObject: DiaryObject)  // 일기 열람 시 조회수 증가
}
