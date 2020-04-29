import MapKit
import RxCocoa
import RxSwift
import UIKit

class SearchViewController: UIViewController, BindableType {
  deinit { print("SearchViewController") }
  var viewModel: SearchViewModel!
  private let disposeBag = DisposeBag()
  private var searchCompleter = MKLocalSearchCompleter()
  private let tableView = UITableView()
  override func viewDidLoad() {
    super.viewDidLoad()
    assemble()
  }

  private func assemble() {
    view.addSubview(tableView)
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 60
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
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
    viewModel.searchString.filter { !$0.isEmpty }.subscribe(onNext: {
      [weak self] searchString in
      self?.searchCompleter.queryFragment = searchString
    }).disposed(by: disposeBag)
    searchCompleter.rx.didUpdateResults.map { $0.results }.bind(
      to: viewModel.items
    ).disposed(by: disposeBag)
    viewModel.items.bind(to: tableView.rx.items) { [weak self] _, _, model in
      self?.createCell(searchResult: model) ?? UITableViewCell()
    }.disposed(by: disposeBag)
    tableView.rx.modelSelected(MKLocalSearchCompletion.self).map {
      MKLocalSearch.getSearch(search: $0)
    }.flatMapLatest { search -> Observable<[MKMapItem]> in
      self.viewModel.mapItems(for: search)
    }.map { $0.first }.unwrappedOptional().map { $0.placemark.coordinate }.bind(
      to: viewModel.resultCoordinate
    ).disposed(by: disposeBag)
    tableView.rx.modelSelected(MKLocalSearchCompletion.self).map { $0.title }
      .bind(to: viewModel.resultString).disposed(by: disposeBag)
  }
}

extension SearchViewController {
  func createCell(searchResult: MKLocalSearchCompletion) -> UITableViewCell {
    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
    cell.textLabel?.text = searchResult.title
    cell.detailTextLabel?.text = searchResult.subtitle
    return cell
  }
}
