import Combine
import MapKit
import SwiftUI

struct DiaryViewerRequest {
    let diaryUseCase: DiaryUseCase = DiaryUseCase()
    let reactionUseCase: ReactionUseCase = ReactionUseCase()
    let userUseCase: UserUseCase = UserUseCase()
    let diary: Diary
    let backButtonEvent: PassthroughSubject<Void, Never>
    let forwardButtonEvent: PassthroughSubject<Void, Never>
}

class DiaryViewerVM: CommonVM<DiaryViewerRequest>, ObservableObject {
    let LOGGER = LoggerProvider.shared.getLogger(classType: DiaryViewerVM.self)

    let diaryUseCase: DiaryUseCase
    let reactionUseCase: ReactionUseCase
    let user: User

    @Published var diary: Diary
    @Published var emotionIcon: UIImage = .init()
    @Published var placeIcon: UIImage = .init()
    @Published var region: MKCoordinateRegion = .init()
    @Published var coordinate: CLLocationCoordinate2D = .init()

    // 공감 이력이 없는 경우 초기값 설정
    lazy var link: DiaryReactionLink = DiaryReactionLink(
        user: user,
        diary: diary,
        reaction: reactionUseCase.readReaction(id: ReactionCode.EMPATHY.rawValue) ?? .init()
    )
    let reactionTrigger = PassthroughSubject<Void, Never>()

    @Published var isEmpathized: Bool = .init()
    @Published var empathyCount: Int = .init()

    private var cancellable = Set<AnyCancellable>()

    override init(
        _ sceneCoordinator: SceneCoordinatorType? = nil,
        _ title: String? = nil,
        _ data: DiaryViewerRequest? = nil
    ) {
        /*
         뷰어 의존성 데이터 준비
         */
        self.diaryUseCase = data?.diaryUseCase ?? .init()
        self.reactionUseCase = data?.reactionUseCase ?? .init()
        self.user = data?.userUseCase.fetchUserSession()?.user ?? .init()
        self.diary = data?.diary ?? .init()

        super.init(sceneCoordinator)

        /*
         뷰어 초기화
         */
        $diary.sink {
            self.emotionIcon =
                $0.emotion.description
                .toImageFromEmoji(imageSize: CGSize(width: 60, height: 60)) ?? .init()
            self.placeIcon =
                $0.emotion.description
                .toImageFromEmoji() ?? .init()
            self.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
            self.coordinate = CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)

            self.readReactions($0)
        }
        .store(in: &cancellable)

        /*
         버튼 매핑
         */
        if let backButtonEvent = data?.backButtonEvent {
            backButtonEvent
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] in
                    self?.pop().execute()
                })
                .store(in: &cancellable)
        }

        if let forwardButtonEvent = data?.forwardButtonEvent {
            forwardButtonEvent
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] in
                    self?.toDiaryEdit()
                })
                .store(in: &cancellable)
        }

        reactionTrigger.debounce(for: .seconds(1), scheduler: RunLoop.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.updateReaction()
            }
            .store(in: &cancellable)
    }

    func reloadDiary() {
        if let new = diaryUseCase.readDiary(uuid: diary.id) {
            self.diary = new
        }
    }

    func readReactions(_ diary: Diary) {
        if diary.shared {
            AnyPublisher<[DiaryReactionLink], Error>.fromAsync {
                try await self.reactionUseCase.getDiaryReactions(self.diary.id)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.LOGGER.errorLog("Failed to read reactions. Cause: \(error)")
                    }
                },
                receiveValue: {
                    if let link = $0.first(where: { $0.user.id == self.user.id }) {
                        self.link = link
                        self.isEmpathized = true
                    } else {
                        self.isEmpathized = false
                    }

                    self.empathyCount = $0.count
                }
            )
            .store(in: &cancellable)
        }
    }

    func updateReaction() {
        AnyPublisher<Any, Error>.fromAsync {
            if self.isEmpathized {
                try await self.reactionUseCase.updateDiaryReaction(self.link)
            } else {
                try await self.reactionUseCase.deleteDiaryReaction(self.link)
            }
        }
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.LOGGER.errorLog("Failed to update reaction. Cause: \(error)")
                }
            },
            receiveValue: { _ in }
        )
        .store(in: &cancellable)
    }
}

extension DiaryViewerVM {
    func toDiaryEdit() {
        let viewModel = DiaryEditWrapperVM(sceneCoordinator, "일기 편집", self.diary)
        let scene = Scene.diaryEditWrapper(viewModel)
        sceneCoordinator?.transition(to: scene, using: .push, animated: true)
    }
}
