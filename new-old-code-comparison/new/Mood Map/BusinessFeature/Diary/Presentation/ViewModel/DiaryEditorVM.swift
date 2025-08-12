import Combine
import UIKit

struct DiaryEditorRequest {
    let mapViewerVM: MapViewerVM
    let mapSearcherVM: MapSearcherVM
    let userUseCase: UserUseCase = UserUseCase()
    let emotionUseCase: EmotionUseCase = EmotionUseCase()
    let diaryUseCase: DiaryUseCase = DiaryUseCase()
    let diary: Diary
    let backButtonEvent: PassthroughSubject<Void, Never>
    let forwardButtonEvent: PassthroughSubject<Void, Never>
}

class DiaryEditorVM: CommonVM<DiaryEditorRequest>, ObservableObject {
    let LOGGER = LoggerProvider.shared.getLogger(classType: DiaryEditorVM.self)

    let mapViewerVM: MapViewerVM
    let mapSearcherVM: MapSearcherVM
    let userUseCase: UserUseCase
    let emotions: [Emotion]
    let emojis: [UIImage]

    @Published var newDiary: Diary
    @Published var emotionIndex = 0

    private var cancellable = Set<AnyCancellable>()

    override init(
        _ sceneCoordinator: SceneCoordinatorType? = nil,
        _ title: String? = nil,
        _ data: DiaryEditorRequest? = nil
    ) {
        self.mapViewerVM = data?.mapViewerVM ?? MapViewerVM()
        self.mapSearcherVM = data?.mapSearcherVM ?? MapSearcherVM()
        self.userUseCase = data?.userUseCase ?? UserUseCase()
        self.emotions = (data?.emotionUseCase ?? EmotionUseCase()).readEmotionsSortedByAsc()
        self.emojis = emotions.compactMap {
            $0.description.toImageFromEmoji(imageSize: CGSize(width: 80, height: 80))
        }
        self.newDiary = data?.diary ?? Diary()

        super.init(sceneCoordinator, title)

        if let data = data {
            setUpNavigationActions(data)
            setUpData(isNew: data.diary.id.isEmpty)
        }
    }

    func setUpNavigationActions(_ data: DiaryEditorRequest) {
        // 이전 화면
        data.backButtonEvent
            .sink(
                receiveValue: { [weak self] _ in
                    self?.pop().execute()
                }
            )
            .store(in: &cancellable)

        // 편집 완료 * 다이어리 id 기준 [작성, 편집] 분기 처리
        data.forwardButtonEvent
            .setFailureType(to: Error.self)
            .map { _ -> AnyPublisher<Diary, Error> in
                data.diary.id.isEmpty
                    ? AnyPublisher<Diary, Error>.fromAsync { try await data.diaryUseCase.createDiary(self.newDiary) }
                    : AnyPublisher<Diary, Error>.fromAsync { try await data.diaryUseCase.updateDiary(self.newDiary) }
            }
            .switchToLatest()  // 중복 요청 시 이전 요청 취소하고 최신 버전만 수행
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.LOGGER.errorLog("Failed to save diary. Cause: \(error)")
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.pop().execute()
                }
            )
            .store(in: &cancellable)
    }

    func setUpData(isNew: Bool) {
        if isNew {
            // ID 설정
            newDiary.id = UUID().uuidString

            // 작성자 설정
            newDiary.user = userUseCase.fetchUserSession()?.user ?? .init()

            // 현재 위치 기반 설정
            mapViewerVM.startUpdatingLocation()

            // 공유 여부 설정
            newDiary.shared = false
        } else if !isNew {
            // 기존 이모션 선택값 설정
            emotionIndex = newDiary.emotion.id - 1

            // 일기 위치 기반 설정
            mapViewerVM.setLocation(
                latitude: newDiary.latitude,
                longitude: newDiary.longitude,
                place: newDiary.place
            )
        }

        // 감정 변경 시 다이어리에 반영
        $emotionIndex.sink {
            self.newDiary.emotion = self.emotions[$0]
        }
        .store(in: &cancellable)

        // 위치 변경 시 다이어리에 반영
        mapViewerVM.$currentMapItem.sink {
            if let name = $0.placemark.name {
                self.newDiary.place = name
            }

            self.newDiary.latitude = $0.placemark.coordinate.latitude
            self.newDiary.longitude = $0.placemark.coordinate.longitude
        }
        .store(in: &cancellable)
    }

    func toMapSearcher() {
        let viewModel = MapSearcherWrapperVM(sceneCoordinator, "장소 선택", mapSearcherVM)
        let scene = Scene.mapSearcherWrapper(viewModel)
        sceneCoordinator?.transition(to: scene, using: .push, animated: true)
    }

    func reloadMapViewer() {
        mapViewerVM.setLocation(
            latitude: newDiary.latitude,
            longitude: newDiary.longitude,
            place: newDiary.place
        )
    }
}
