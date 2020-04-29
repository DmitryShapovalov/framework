import RxCocoa
import RxSwift
import SnapKit
import UIKit

class TripListScreenViewController: UIViewController, BindableType {
  deinit { print("TripListScreenViewController") }
  private let tableView = UITableView()
  private var btCreate = UIBarButtonItem(
    barButtonSystemItem: .add,
    target: nil,
    action: nil
  )
  var viewModel: TripListViewModel!
  private let disposeBag = DisposeBag()
  override func viewDidLoad() {
    super.viewDidLoad()
    assemble()
  }

  private func assemble() {
    title = "Trips"
    view.addSubview(tableView)
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 60
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    navigationItem.rightBarButtonItem = btCreate
    setupLayout()
  }

  private func setupLayout() {
    tableView.snp.makeConstraints { make in make.top.equalTo(view.snp.top)
      make.bottom.equalTo(view.snp.bottom)
      make.left.equalTo(view.snp.left)
      make.right.equalTo(view.snp.right)
    }
  }

  func bindViewModel() {
    btCreate.rx.tap.asDriver().drive(onNext: { _ in
      self.viewModel.onCreateTrip()
    }).disposed(by: disposeBag)
    viewModel.tripList.bind(to: tableView.rx.items) { _, _, model in
      let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
      cell.textLabel?.text = "TripID: \(model.trip_id ?? "null")"
      cell.detailTextLabel?.text =
        "Started at: \(DateFormatter.convertStringDateToLocalTime(time: model.started_at ?? "0"))"
      return cell
    }.disposed(by: disposeBag)
    Observable.zip(
      tableView.rx.itemSelected,
      tableView.rx.modelSelected(TripModel.self)
    ).bind { [weak self] indexPath, model in
      guard let self = self else { return }
      self.viewModel.onDisplayTrip(trip: model)
      self.tableView.deselectRow(at: indexPath, animated: true)
    }.disposed(by: disposeBag)
    rx.viewDidAppear.subscribe { [weak self] _ in
      guard let self = self else { return }
      self.viewModel.fetchTrips()
    }.disposed(by: disposeBag)
  }
}
