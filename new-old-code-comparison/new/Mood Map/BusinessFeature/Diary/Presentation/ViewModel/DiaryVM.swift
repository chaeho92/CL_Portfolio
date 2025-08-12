import Action
import RxSwift

struct DiaryRequest {
    let diaryUseCase: DiaryUseCase = DiaryUseCase()
    let emotionUseCase: EmotionUseCase = EmotionUseCase()
}

class DiaryVM: CommonVM<DiaryRequest> {
    let diaryUseCase: DiaryUseCase

    // 달력 페이지 변경사항 관리
    let calendarDateSubject = BehaviorSubject<Date>(value: Date())

    // 달력 조회 날짜 최소, 최대 제약조건 설정
    var calendarDateObservable: Observable<Date> {
        calendarDateSubject.distinctUntilChanged().share().map {
            let minimumDate = Date(timeIntervalSince1970: 0)
            let currentDate = Date()

            if $0 < minimumDate {
                return minimumDate
            } else if $0 > currentDate {
                return currentDate
            } else {
                return $0
            }
        }
    }

    // 달력 날짜 선택 시 감지
    let selectedDateSubject = BehaviorSubject<Date>(value: Date())

    // 다이어리 목록의 변경을 감지
    let listUpdateTriggerSubject = PublishSubject<Void>()

    // 목록에 표시할 다이어리 배열
    var listDiaries: [Diary] = []

    // 이모지 배열
    let emojis: [Int: String]
    let emojiImages: [Int: UIImage]

    let bag = DisposeBag()

    override init(
        _ sceneCoordinator: SceneCoordinatorType? = nil,
        _ title: String? = nil,
        _ data: DiaryRequest? = nil
    ) {
        self.diaryUseCase = data?.diaryUseCase ?? DiaryUseCase()

        // 이모션 파생 프로퍼티 초기화
        let emotions = (data?.emotionUseCase ?? EmotionUseCase()).readEmotionsSortedByAsc()
        var emojis = [Int: String]()
        var emojiImages = [Int: UIImage]()
        emotions.forEach {
            emojis[$0.id] = $0.description
            emojiImages[$0.id] = $0.description.toImageFromEmoji()
        }
        self.emojis = emojis
        self.emojiImages = emojiImages

        super.init(sceneCoordinator, title)

        // 달력에서 날짜 선택 시 목록 업데이트
        selectedDateSubject.subscribe(onNext: { date in
            self.listDiaries.removeAll()
            self.listDiaries = self.diaryUseCase.readDiariesForList(date: date).sorted(by: {
                $0.occurredAt > $1.occurredAt
            })

            self.listUpdateTriggerSubject.onNext(())
        }).disposed(by: bag)
    }

    // 달력에 적용할 다이어리 획득
    func readDiariesForCalendar(date: Date) -> Diary? {
        diaryUseCase.readDiariesForCalendar(date: date).last
    }

    // 저장소 다이어리 업데이트
    func updateDiary(diary: Diary) -> Observable<Diary> {
        Observable<Diary>.fromAsync { try await self.diaryUseCase.updateDiary(diary) }
    }

    // 저장소 다이어리 제거
    func deleteDiary(diary: Diary) -> Observable<Void> {
        Observable<Void>.fromAsync { try await self.diaryUseCase.deleteDiary(diary) }
    }

    // 날짜 선택을 위한 화면 전환
    func toDatePicker() -> CocoaAction {
        CocoaAction {
            let viewModel = DatePickerVM(self.sceneCoordinator, "날짜 선택", self.calendarDateSubject)
            let scene = Scene.datePicker(viewModel)
            return self.sceneCoordinator!.transition(to: scene, using: .push, animated: true)
                .asObservable().map { _ in }
        }
    }

    // 다이어리 작성 화면 전환
    func toDiaryEdit() -> CocoaAction {
        CocoaAction {
            var occurredAt = Date()
            if let selectedDate = try? self.selectedDateSubject.value() {
                occurredAt = selectedDate < occurredAt ? selectedDate : occurredAt
            }

            let viewModel = DiaryEditWrapperVM(
                self.sceneCoordinator, "일기 작성", Diary(occurredAt: occurredAt)
            )
            let scene = Scene.diaryEditWrapper(viewModel)
            return self.sceneCoordinator!.transition(to: scene, using: .push, animated: true)
                .asObservable().map { _ in }
        }
    }

    // 다이어리 세부 화면 전환
    func toDiaryViewer(diary: Diary) -> CocoaAction {
        CocoaAction {
            let viewModel = DiaryViewerWrapperVM(self.sceneCoordinator, "내 일기", diary)
            let scene = Scene.diaryViewerWrapper(viewModel)
            return self.sceneCoordinator!.transition(to: scene, using: .push, animated: true)
                .asObservable().map { _ in }
        }
    }
}
