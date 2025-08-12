import Action
import Combine

class DiaryEditWrapperVM: CommonVM<Diary> {
    let backButtonEvent = PassthroughSubject<Void, Never>()
    let forwardButtonEvent = PassthroughSubject<Void, Never>()

    let diaryEditorVM: DiaryEditorVM

    override init(
        _ sceneCoordinator: SceneCoordinatorType? = nil,
        _ title: String? = nil,
        _ data: Diary? = nil
    ) {
        let locationManager = LocationManager()
        let mapRequest = MapRequest()

        let mapViewerVM = MapViewerVM(
            sceneCoordinator, nil,
            MapViewerRequest(
                locationManager: locationManager, mapRequest: mapRequest
            )
        )
        let mapSearcherVM = MapSearcherVM(
            sceneCoordinator, nil,
            MapSearcherRequest(
                locationManager: locationManager, mapRequest: mapRequest
            )
        )

        self.diaryEditorVM = DiaryEditorVM(
            sceneCoordinator, nil,
            DiaryEditorRequest(
                mapViewerVM: mapViewerVM,
                mapSearcherVM: mapSearcherVM,
                diary: data ?? Diary(),
                backButtonEvent: backButtonEvent,
                forwardButtonEvent: forwardButtonEvent
            ))

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
