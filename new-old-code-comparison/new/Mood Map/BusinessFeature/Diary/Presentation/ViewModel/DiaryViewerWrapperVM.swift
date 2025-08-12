import Action
import Combine

class DiaryViewerWrapperVM: CommonVM<Diary> {
    let backButtonEvent = PassthroughSubject<Void, Never>()
    let forwardButtonEvent = PassthroughSubject<Void, Never>()

    let diaryViewerVM: DiaryViewerVM

    override init(
        _ sceneCoordinator: SceneCoordinatorType? = nil,
        _ title: String? = nil,
        _ data: Diary? = nil
    ) {
        self.diaryViewerVM = DiaryViewerVM(
            sceneCoordinator, nil,
            DiaryViewerRequest(
                diary: data ?? Diary(),
                backButtonEvent: backButtonEvent,
                forwardButtonEvent: forwardButtonEvent
            )
        )

        let title =
            diaryViewerVM.user.id == diaryViewerVM.diary.user.id ? title : "\(diaryViewerVM.diary.user.name)님의 일기"

        super.init(sceneCoordinator, title, data)
    }

    func tapBackButton() -> CocoaAction {
        CocoaAction {
            self.backButtonEvent.send()
            return .empty()
        }
    }

    func tapForwardButton() -> CocoaAction {
        CocoaAction {
            self.forwardButtonEvent.send()
            return .empty()
        }
    }
}
