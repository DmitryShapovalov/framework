import MapKit
import RxCocoa
import RxSwift
import SnapKit
import UIKit

class EditTripViewController: UIViewController, BindableType {
  deinit { print("EditTripViewController") }
  var viewModel: EditTripViewModel!
  private let disposeBag = DisposeBag()
  // Navigation "Done" button
  private var btCreate = UIBarButtonItem(
    barButtonSystemItem: .done,
    target: nil,
    action: nil
  )
  private let scrollView = UIScrollView()
  private let stackView = UIStackView()
  // Coordinate stack part
  private let coordContainer = UIView()
  private let coordLabel = UILabel()
  private let coordDevider = UIView()
  // MapView stack part
  private let mapContainer = UIView()
  private var btOpenMap = UIButton()
  private let mapDevider = UIView()
  // Radius stack part
  private let radiusContainer = UIView()
  private let radiusLabel = UILabel()
  private let radiusCountLabel = UILabel()
  private let radiusControl = UIStepper()
  private let radiusDevider = UIView()
  // Scheduled at stack part
  private let scheduledAtContainer = UIView()
  private let scheduledATitleLabel = UILabel()
  private let dateLabel = UILabel()
  private let timeLabel = UILabel()
  private let dateTextField = UITextField()
  private let timeTextField = UITextField()
  private let datePicker = UIDatePicker()
  private let timePicker = UIDatePicker()
  private let scheduledAtDevider = UIView()
  private let dateDevider = UIView()
  private let timeDevider = UIView()
  // Metadata stack part
  private let metaContainer = UIView()
  private let metaLabel = UILabel()
  private let metaTextView = UITextView()
  private var searchController: UISearchController!
  private var searchResultTableViewController: SearchViewController!
  override func viewDidLoad() {
    super.viewDidLoad()
    assemble()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    navigationItem.hidesSearchBarWhenScrolling = true
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // Set 52.0pt like value to scrollview ContentSize for fix hide/show SearchBar
    scrollView.contentSize = CGSize(
      width: stackView.frame.width,
      height: stackView.frame.height + 52.0
    )
  }

  private func assemble() {
    title = "Create"
    definesPresentationContext = true
    searchResultTableViewController = SearchViewController()
    searchResultTableViewController.viewModel = SearchViewModel()
    searchResultTableViewController.bindViewModel()

    searchController = UISearchController(
      searchResultsController: searchResultTableViewController
    )
    searchController.hidesNavigationBarDuringPresentation = true
    searchController.dimsBackgroundDuringPresentation = false
    navigationItem.rightBarButtonItem = btCreate
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    view.backgroundColor = .white

    scrollView.showsVerticalScrollIndicator = false
    stackView.axis = .vertical
    radiusLabel.text = "Radius"
    radiusCountLabel.text = "30"
    radiusControl.tintColor = .black
    btOpenMap.setTitle("Set location on map", for: .normal)
    btOpenMap.setTitleColor(.black, for: .normal)
    btOpenMap.setTitleColor(.gray, for: .highlighted)
    scheduledATitleLabel.text = "Scheduled at"
    dateLabel.text = "Date"
    timeLabel.text = "Time"
    metaLabel.text = "Metadata"
    coordLabel.numberOfLines = 0
    radiusDevider.backgroundColor = .lightGray
    mapDevider.backgroundColor = .lightGray
    radiusDevider.backgroundColor = .lightGray
    scheduledAtDevider.backgroundColor = .lightGray
    timeDevider.backgroundColor = .lightGray
    dateDevider.backgroundColor = .lightGray
    coordDevider.backgroundColor = .lightGray
    dateTextField.borderStyle = .none
    dateTextField.layer.cornerRadius = 15
    dateTextField.tintColor = .clear
    dateTextField.layer.borderWidth = 1
    dateTextField.layer.borderColor = UIColor.black.cgColor
    dateTextField.inputView = datePicker
    dateTextField.textAlignment = .center
    timeTextField.borderStyle = .none
    timeTextField.layer.cornerRadius = 15
    timeTextField.tintColor = .clear
    timeTextField.layer.borderWidth = 1
    timeTextField.layer.borderColor = UIColor.black.cgColor
    timeTextField.inputView = timePicker
    timeTextField.textAlignment = .center
    datePicker.datePickerMode = .date
    datePicker.backgroundColor = .lightGray
    timePicker.datePickerMode = .time
    timePicker.backgroundColor = .lightGray
    metaTextView.text = ""
    metaTextView.layer.cornerRadius = 5
    metaTextView.layer.borderColor = UIColor.black.cgColor
    metaTextView.layer.borderWidth = 1.0
    metaTextView.tintColor = .black
    metaTextView.autocorrectionType = .no
    hideKeyboardWhenTapped()
    setupLayout()
  }

  private func setupLayout() {
    view.addSubview(scrollView)
    scrollView.addSubview(stackView)
    coordContainer.addSubview(coordLabel)
    coordContainer.addSubview(coordDevider)
    mapContainer.addSubview(btOpenMap)
    mapContainer.addSubview(mapDevider)
    radiusContainer.addSubview(radiusLabel)
    radiusContainer.addSubview(radiusCountLabel)
    radiusContainer.addSubview(radiusControl)
    radiusContainer.addSubview(radiusDevider)
    scheduledAtContainer.addSubview(scheduledATitleLabel)
    scheduledAtContainer.addSubview(dateLabel)
    scheduledAtContainer.addSubview(timeLabel)
    scheduledAtContainer.addSubview(dateTextField)
    scheduledAtContainer.addSubview(timeTextField)
    scheduledAtContainer.addSubview(scheduledAtDevider)
    scheduledAtContainer.addSubview(dateDevider)
    scheduledAtContainer.addSubview(timeDevider)
    metaContainer.addSubview(metaLabel)
    metaContainer.addSubview(metaTextView)
    stackView.addArrangedSubview(coordContainer)
    stackView.addArrangedSubview(mapContainer)
    stackView.addArrangedSubview(radiusContainer)
    stackView.addArrangedSubview(scheduledAtContainer)
    stackView.addArrangedSubview(metaContainer)
    dateLabel.translatesAutoresizingMaskIntoConstraints = false
    timeLabel.translatesAutoresizingMaskIntoConstraints = false
    metaLabel.translatesAutoresizingMaskIntoConstraints = false
    stackView.translatesAutoresizingMaskIntoConstraints = false
    btOpenMap.translatesAutoresizingMaskIntoConstraints = false
    coordLabel.translatesAutoresizingMaskIntoConstraints = false
    mapDevider.translatesAutoresizingMaskIntoConstraints = false
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    dateDevider.translatesAutoresizingMaskIntoConstraints = false
    timeDevider.translatesAutoresizingMaskIntoConstraints = false
    radiusLabel.translatesAutoresizingMaskIntoConstraints = false
    coordDevider.translatesAutoresizingMaskIntoConstraints = false
    metaTextView.translatesAutoresizingMaskIntoConstraints = false
    mapContainer.translatesAutoresizingMaskIntoConstraints = false
    radiusControl.translatesAutoresizingMaskIntoConstraints = false
    radiusDevider.translatesAutoresizingMaskIntoConstraints = false
    dateTextField.translatesAutoresizingMaskIntoConstraints = false
    timeTextField.translatesAutoresizingMaskIntoConstraints = false
    metaContainer.translatesAutoresizingMaskIntoConstraints = false
    metaContainer.translatesAutoresizingMaskIntoConstraints = false
    coordContainer.translatesAutoresizingMaskIntoConstraints = false
    radiusContainer.translatesAutoresizingMaskIntoConstraints = false
    radiusCountLabel.translatesAutoresizingMaskIntoConstraints = false
    scheduledAtDevider.translatesAutoresizingMaskIntoConstraints = false
    scheduledATitleLabel.translatesAutoresizingMaskIntoConstraints = false
    scheduledAtContainer.translatesAutoresizingMaskIntoConstraints = false
    scrollView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
      make.left.equalTo(view.snp.left)
      make.right.equalTo(view.snp.right)
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
    }
    stackView.snp.makeConstraints { make in make.top.equalTo(scrollView.snp.top)
      make.left.equalTo(scrollView.snp.left)
      make.right.equalTo(scrollView.snp.right)
      make.bottom.equalTo(scrollView.snp.bottom)
      make.width.equalTo(view.snp.width)
    }
    coordContainer.snp.makeConstraints { make in
      make.top.equalTo(stackView.snp.top)
      make.left.equalTo(stackView.snp.left)
      make.right.equalTo(stackView.snp.right)
      make.height.equalTo(50)
    }
    coordLabel.snp.makeConstraints { make in
      make.top.equalTo(coordContainer.snp.top)
      make.left.equalTo(coordContainer.snp.left).offset(18)
      make.bottom.equalTo(coordContainer.snp.bottom)
      make.right.equalTo(coordContainer.snp.right).offset(-18)
    }
    coordDevider.snp.makeConstraints { make in
      make.right.equalTo(coordContainer.snp.right)
      make.left.equalTo(coordContainer.snp.left)
      make.bottom.equalTo(coordContainer.snp.bottom)
      make.height.equalTo(1)
    }
    mapContainer.snp.makeConstraints { make in
      make.left.equalTo(stackView.snp.left)
      make.right.equalTo(stackView.snp.right)
      make.height.equalTo(50)
    }
    btOpenMap.snp.makeConstraints { make in
      make.top.equalTo(mapContainer.snp.top)
      make.right.equalTo(-18)
      make.bottom.equalTo(mapContainer.snp.bottom)
    }
    mapDevider.snp.makeConstraints { make in
      make.right.equalTo(mapContainer.snp.right)
      make.left.equalTo(mapContainer.snp.left)
      make.bottom.equalTo(mapContainer.snp.bottom)
      make.height.equalTo(1)
    }
    radiusContainer.snp.makeConstraints { make in
      make.left.equalTo(stackView.snp.left)
      make.right.equalTo(stackView.snp.right)
      make.height.equalTo(50)
    }
    radiusLabel.snp.makeConstraints { make in
      make.top.equalTo(radiusContainer.snp.top)
      make.left.equalTo(radiusContainer.snp.left).offset(18)
      make.bottom.equalTo(radiusContainer.snp.bottom)
    }
    radiusControl.snp.makeConstraints { make in
      make.right.equalTo(radiusContainer.snp.right).offset(-18)
      make.centerY.equalTo(radiusLabel)
    }
    radiusCountLabel.snp.makeConstraints { make in
      make.right.equalTo(radiusControl.snp.left).offset(-10)
      make.centerY.equalTo(radiusLabel)
    }
    radiusDevider.snp.makeConstraints { make in
      make.right.equalTo(radiusContainer.snp.right)
      make.left.equalTo(radiusContainer.snp.left)
      make.bottom.equalTo(radiusContainer.snp.bottom)
      make.height.equalTo(1)
    }
    scheduledAtContainer.snp.makeConstraints { make in
      make.left.equalTo(stackView.snp.left)
      make.right.equalTo(stackView.snp.right)
      make.height.equalTo(150)
    }
    scheduledATitleLabel.snp.makeConstraints { make in
      make.top.equalTo(scheduledAtContainer.snp.top)
      make.left.equalTo(scheduledAtContainer.snp.left).offset(50)
      make.right.equalTo(scheduledAtContainer.snp.right)
      make.height.equalTo(50)
    }
    dateLabel.snp.makeConstraints { make in
      make.top.equalTo(scheduledATitleLabel.snp.bottom)
      make.left.equalTo(scheduledAtContainer.snp.left).offset(50)
      make.height.equalTo(40)
    }
    timeLabel.snp.makeConstraints { make in
      make.top.equalTo(dateLabel.snp.bottom)
      make.left.equalTo(scheduledAtContainer.snp.left).offset(50)
      make.height.equalTo(40)
    }
    dateTextField.snp.makeConstraints { make in
      make.top.equalTo(dateLabel.snp.top).offset(5)
      make.bottom.equalTo(dateLabel.snp.bottom).offset(-5)
      make.right.equalTo(scheduledAtContainer.snp.right).offset(-18)
      make.width.equalTo(view.frame.width * 0.3)
    }
    timeTextField.snp.makeConstraints { make in
      make.top.equalTo(timeLabel.snp.top).offset(5)
      make.bottom.equalTo(timeLabel.snp.bottom).offset(-5)
      make.right.equalTo(scheduledAtContainer.snp.right).offset(-18)
      make.left.equalTo(timeLabel.snp.right).offset(20)
      make.width.equalTo(view.frame.width * 0.3)
    }
    scheduledAtDevider.snp.makeConstraints { make in
      make.right.equalTo(scheduledATitleLabel.snp.right)
      make.left.equalTo(scheduledATitleLabel.snp.left)
      make.bottom.equalTo(scheduledATitleLabel.snp.bottom)
      make.height.equalTo(1)
    }
    dateDevider.snp.makeConstraints { make in
      make.right.equalTo(scheduledAtContainer.snp.right)
      make.left.equalTo(dateLabel.snp.left)
      make.bottom.equalTo(dateLabel.snp.bottom)
      make.height.equalTo(1)
    }
    timeDevider.snp.makeConstraints { make in
      make.right.equalTo(scheduledAtContainer.snp.right)
      make.left.equalTo(timeLabel.snp.left)
      make.bottom.equalTo(timeLabel.snp.bottom)
      make.height.equalTo(1)
    }
    metaContainer.snp.makeConstraints { make in
      make.left.equalTo(stackView.snp.left)
      make.right.equalTo(stackView.snp.right)
      make.height.equalTo(300)
    }
    metaLabel.snp.makeConstraints { make in
      make.top.equalTo(metaContainer.snp.top).offset(5)
      make.left.equalTo(metaContainer.snp.left).offset(20)
    }
    metaTextView.snp.makeConstraints { make in
      make.top.equalTo(metaLabel.snp.bottom).offset(20)
      make.bottom.equalTo(metaContainer.snp.bottom).offset(-20)
      make.right.equalTo(metaContainer.snp.right).offset(-20)
      make.left.equalTo(metaContainer.snp.left).offset(20)
    }
  }

  func bindViewModel() {
    btCreate.rx.tap.asDriver().drive(onNext: { [weak self] _ in
      guard let self = self else { return }
      self.viewModel.onCreateTrip()
    }).disposed(by: disposeBag)
    viewModel.requestProcessing.asDriver().drive(onNext: { [weak self] state in
      guard let self = self else { return }
      self.onDisplayActivityView(state: state)
    }).disposed(by: disposeBag)
    btOpenMap.rx.tap.asDriver().drive(onNext: { [weak self] _ in
      guard let self = self else { return }
      self.viewModel.onOpenMap()
    }).disposed(by: disposeBag)
    let dateObserver = Observable.combineLatest(
      viewModel.dateObservable,
      viewModel.timeObservable
    ) { Date.combineDateWithTime(date: $0, time: $1) }
    viewModel.radius.map { Double($0) }.bind(to: radiusControl.rx.value)
      .disposed(by: disposeBag)
    radiusControl.rx.value.map { Int($0) }.bind(to: viewModel.radius).disposed(
      by: disposeBag
    )
    radiusControl.rx.value.map { String(Int($0)) }.bind(
      to: radiusCountLabel.rx.text
    ).disposed(by: disposeBag)
    datePicker.rx.value.bind(to: viewModel.dateObservable).disposed(
      by: disposeBag
    )
    timePicker.rx.value.bind(to: viewModel.timeObservable).disposed(
      by: disposeBag
    )
    dateObserver.map {
      DateFormatter.iso8601Full.string(from: $0.addingTimeInterval(5.0 * 60.0))
    }.bind(to: viewModel.scheduled_at).disposed(by: disposeBag)
    datePicker.rx.value.map { $0.dateToString() }.bind(
      to: dateTextField.rx.text
    ).disposed(by: disposeBag)
    timePicker.rx.value.map { $0.timeToString() }.bind(
      to: timeTextField.rx.text
    ).disposed(by: disposeBag)
    metaTextView.rx.text.orEmpty.bind(to: viewModel.metadata).disposed(
      by: disposeBag
    )
    searchController.searchBar.rx.text.asObservable().map {
      ($0 ?? "").lowercased()
    }.bind(to: searchResultTableViewController.viewModel.searchString).disposed(
      by: disposeBag
    )
    searchResultTableViewController.viewModel.resultString.subscribe(onNext: {
      [weak self] result in guard let self = self else { return }
      self.searchController.searchBar.text = result
    }).disposed(by: disposeBag)
    searchResultTableViewController.viewModel.resultCoordinate.bind(
      to: viewModel.coordinates
    ).disposed(by: disposeBag)
    searchResultTableViewController.viewModel.resultCoordinate.subscribe {
      [weak self] _ in guard let self = self else { return }
      self.searchController.dismiss(animated: true, completion: nil)
    }.disposed(by: disposeBag)
    viewModel.coordinates.bind { [weak self] in
      guard let self = self else { return }
      self.coordLabel.text = "lat: \($0.latitude)\nlng: \($0.longitude)"
    }.disposed(by: disposeBag)
  }
}

extension EditTripViewController {
  private func onDisplayActivityView(state: Bool) {
    if state { ActivityIndicatorView.startAnimatingOnView() } else {
      ActivityIndicatorView.stopAnimationOnView()
    }
  }
}
