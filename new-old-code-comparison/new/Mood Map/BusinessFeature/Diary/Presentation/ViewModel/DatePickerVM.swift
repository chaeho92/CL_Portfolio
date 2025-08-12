import Action
import RxSwift

class DatePickerVM: CommonVM<BehaviorSubject<Date>> {

    let dateSubject: BehaviorSubject<Date>

    var dateObservable: Observable<Date> {
        dateSubject.map {
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

    let bag = DisposeBag()

    override init(
        _ sceneCoordinator: SceneCoordinatorType? = nil,
        _ title: String? = nil,
        _ data: BehaviorSubject<Date>? = nil
    ) {
        dateSubject = BehaviorSubject(value: try! data!.value())

        super.init(sceneCoordinator, title, data)
    }

    func close() -> CocoaAction {
        CocoaAction {
            self.dateObservable.bind(to: self.data!).disposed(by: self.bag)
            return self.sceneCoordinator!.pop(animated: true).asObservable().map { _ in }
        }
    }

}
