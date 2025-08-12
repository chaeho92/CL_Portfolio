import RxSwift

class DatePickerVC: CommonVC, ViewModelBindableType {
    @IBOutlet weak var yearMonthPicker: YearMonthPicker!

    private lazy var backButton: UIBarButtonItem = onBackButton(target: self)

    private let bag = DisposeBag()

    public var viewModel: DatePickerVM!

    func bindViewModel() {
        backButton.rx.action = viewModel.close()

        viewModel.dateObservable.take(1).bind(to: yearMonthPicker.inputDate).disposed(by: bag)
        yearMonthPicker.outputDate.bind(to: viewModel.dateSubject).disposed(by: bag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        title = viewModel.title
        navigationController?.navigationBar.prefersLargeTitles = false
        tabBarController?.tabBar.isHidden = true
    }
}
