import RxSwift

protocol DiaryService {
    // 공유 일기 추가
    func updateDiary(_ diary: Diary) -> Observable<Diary>
    // 공유 일기 제거
    func deleteDiaryById(_ id: String) -> Observable<Void>
    // 공유 일기 조회 - 지도 범위 기준
    func getDiariesByLocationAndShared(latitude: Double, longitude: Double, range: Double) -> Observable<[Diary]>
    // 공유 일기 조회 - UUID 기준
    func getDiaryById(_ id: String) -> Observable<Diary>

    // 일기 복구 - 재설치 시
    func restoreDiaries(userId: Int) -> Observable<[Diary]>
}
