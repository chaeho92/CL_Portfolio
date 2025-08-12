import RxSwift

class DiaryViewerWrapperVC: CommonVC, ViewModelBindableType {
    private lazy var backButton: UIBarButtonItem = onBackButton(target: self)
    private lazy var forwardButton: UIBarButtonItem = onForwardButton(target: self)

    var viewModel: DiaryViewerWrapperVM!

    func bindViewModel() {
        backButton.rx.action = viewModel.tapBackButton()
        forwardButton.rx.action = viewModel.tapForwardButton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        setUpView()
        setUpSwiftUiView(DiaryViewer(viewModel: self.viewModel.diaryViewerVM))
    }

    override func viewWillAppear(_ animated: Bool) {
        refreshView()
    }

    func setUpView() {
        let shared = viewModel.data?.shared ?? false
        forwardButton.isEnabled = !shared
        forwardButton.isHidden = shared
    }

    func refreshView() {
        title = viewModel.title
        navigationController?.navigationBar.prefersLargeTitles = false
        tabBarController?.tabBar.isHidden = true
    }
}
