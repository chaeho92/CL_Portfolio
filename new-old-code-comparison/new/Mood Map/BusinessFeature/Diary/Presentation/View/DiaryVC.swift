import FSCalendar
import RxCocoa
import RxSwift

class DiaryVC: CommonVC, ViewModelBindableType {
    // Calendar Header
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    var writeButton = ButtonCreator(
        ButtonProperty(
            image: UIImage(systemName: "square.and.pencil")!, backgroundColor: .systemGreen, tintColor: .white,
            alpha: 0.9, cornerRadius: 25, size: CGSize(width: 50, height: 50)
        )
    ).create()

    // Calendar Body
    @IBOutlet weak var calendar: FSCalendar!

    // Diary List
    @IBOutlet weak var diaryTableView: UITableView!

    private let bag = DisposeBag()

    var viewModel: DiaryVM!

    func bindViewModel() {
        setUpViewBindings()
        setUpCalendarViewBindings()
        setUpListViewBindings()
    }

    override func viewDidLoad() {
        setUpView()
        setUpCalendarView()
        setUpListView()

        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        refreshView()
        refreshCalendarView()
        refreshListView()
    }

    func setUpView() {
        view.addSubview(writeButton)
        NSLayoutConstraint.activate([
            writeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            writeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
        ])
    }

    func setUpViewBindings() {
        writeButton.rx.action = viewModel.toDiaryEdit()
    }

    func refreshView() {
        title = viewModel.title
        navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.tabBar.isHidden = false
    }
}

extension DiaryVC: FSCalendarDelegate, FSCalendarDataSource {
    func setUpCalendarView() {
        calendar.delegate = self
        calendar.dataSource = self

        calendar.headerHeight = 0  // 커스텀 헤더 사용을 위해 FSCalendar 헤더 제거
        calendar.scrollEnabled = false  // 좌우 스크롤 날짜 변경 차단
    }

    func setUpCalendarViewBindings() {
        // 사용자 입력에 의한 화면 전환 시 헤더 수정
        viewModel.calendarDateObservable.map { $0.string(format: "yyyy년 MM월") }
            .bind(to: dateLabel.rx.text).disposed(by: bag)

        // 사용자 입력에 의한 화면 전환
        viewModel.calendarDateObservable
            .bind(to: calendar.rx.currentPage).disposed(by: bag)

        // 이전, 다음 버튼 입력에 의한 화면 전환
        Observable.merge(previousButton.rx.tap.map { -1 }, nextButton.rx.tap.map { 1 })
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .withLatestFrom(viewModel.calendarDateObservable) { offset, date in
                guard self.calendar.scope.rawValue == 0 else {  // FSCalendar의 월, 주 단위 Scope 분기
                    return Calendar.current.date(byAdding: .weekOfMonth, value: offset, to: date)
                }
                return Calendar.current.date(byAdding: .month, value: offset, to: date)
            }.compactMap { $0 }.bind(to: viewModel.calendarDateSubject).disposed(by: bag)

        // 오리엔테이션 변경 시 화면 전환
        NotificationCenter.default.rx.notification(UIDevice.orientationDidChangeNotification)
            .map { _ in UIDevice.current.orientation }
            .subscribe(onNext: { orientation in
                switch orientation {
                case .portrait:
                    self.calendar.scope = .month  // Scope 전환이 없으면 화면비 정렬이 무시됨
                    self.calendar.reloadData()
                case .landscapeLeft, .landscapeRight:
                    self.calendar.scope = .week  // Scope 전환이 없으면 화면비 정렬이 무시됨
                    self.calendar.reloadData()
                default:
                    break
                }
            })
            .disposed(by: bag)

        // DatePicker 화면 전환
        dateButton.rx.action = viewModel.toDatePicker()
    }

    func refreshCalendarView() {
        calendar.reloadData()
    }

    // 페이지 전환 시 호출되며 날짜 하단 이미지를 설정
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        guard let diary = viewModel.readDiariesForCalendar(date: date) else { return nil }
        return viewModel.emojiImages[diary.emotion.id]
    }

    // 달력에서 날짜 선택 * 문자열 변환 시 UTC/Local Time 차이로 예상 시간과 상이하게 출력될 수 있음
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        viewModel.selectedDateSubject.onNext(date)
    }
}

extension DiaryVC: UITableViewDelegate, UITableViewDataSource {
    func setUpListView() {
        diaryTableView.delegate = self
        diaryTableView.dataSource = self
    }

    func setUpListViewBindings() {
        viewModel.listUpdateTriggerSubject.subscribe(onNext: {
            self.diaryTableView.reloadData()
        }).disposed(by: bag)
    }

    func refreshListView() {
        viewModel.selectedDateSubject.onNext(calendar.selectedDate ?? Date())
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listDiaries.count
    }

    // 목록 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "diaryTVC", for: indexPath) as? DiaryTVC else {
            return UITableViewCell()
        }

        let diary = viewModel.listDiaries[indexPath.row]

        cell.shareIcon.tintColor = diary.shared ? .label : .secondarySystemBackground
        cell.emotion.text = viewModel.emojis[diary.emotion.id]
        cell.date.text = diary.occurredAt.string(format: "yyyy. MM. dd")
        cell.title.text = diary.title.isEmpty ? "제목 없음" : diary.title
        cell.location.text = diary.place.isEmpty ? "장소 없음" : diary.place

        return cell
    }

    // 목록 선택
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.toDiaryViewer(diary: self.viewModel.listDiaries[indexPath.row]).execute()
    }

    // 목록 삭제
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { (_, _, completionHandler) in
            self.viewModel.deleteDiary(diary: self.viewModel.listDiaries[indexPath.row])
                .observe(on: MainScheduler.instance)
                .subscribe(
                    onNext: { _ in
                        self.viewModel.listDiaries.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)

                        completionHandler(true)

                        self.refreshCalendarView()
                    },
                    onError: { _ in
                        completionHandler(false)
                    }
                )
                .disposed(by: self.bag)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    // 공유 설정
    func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let shareAction = UIContextualAction(style: .normal, title: "공유") { (_, _, completionHandler) in
            self.viewModel.listDiaries[indexPath.row].shared.toggle()
            self.viewModel.updateDiary(diary: self.viewModel.listDiaries[indexPath.row])
                .observe(on: MainScheduler.instance)
                .subscribe(
                    onNext: { _ in
                        self.refreshListView()

                        completionHandler(true)
                    },
                    onError: { _ in
                        completionHandler(false)
                    }
                )
                .disposed(by: self.bag)
        }

        return UISwipeActionsConfiguration(actions: [shareAction])
    }
}
