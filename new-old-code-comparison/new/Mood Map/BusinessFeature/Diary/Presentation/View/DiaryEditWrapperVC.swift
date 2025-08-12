import RxSwift

class DiaryEditWrapperVC: CommonVC, ViewModelBindableType {
    private lazy var backButton: UIBarButtonItem = onBackButton(target: self)
    private lazy var forwardButton: UIBarButtonItem = onForwardButton(target: self)

    var viewModel: DiaryEditWrapperVM!

    func bindViewModel() {
        backButton.rx.action = viewModel.tapBackButton()
        forwardButton.rx.action = viewModel.tapForwardButton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        setUpSwiftUiView(DiaryEditor(viewModel: self.viewModel.diaryEditorVM))
    }

    override func viewWillAppear(_ animated: Bool) {
        refreshView()
    }

    func refreshView() {
        title = viewModel.title
        navigationController?.navigationBar.prefersLargeTitles = false
        tabBarController?.tabBar.isHidden = true
    }
}
