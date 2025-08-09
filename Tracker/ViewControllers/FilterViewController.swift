import UIKit
import SnapKit
import AppMetricaCore

// MARK: - Filter Selection Delegate
protocol FilterViewControllerDelegate: AnyObject {
    func filterViewController(_ controller: FilterViewController, didSelect filter: TrackersViewModel.FilterType)
}

// MARK: - FilterViewController
final class FilterViewController: UIViewController {

    // MARK: - UI Elements
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    // MARK: - Properties
    private let filters: [TrackersViewModel.FilterType]
    private let currentFilter: TrackersViewModel.FilterType
    weak var delegate: FilterViewControllerDelegate?

    // MARK: - Lifecycle
    init(currentFilter: TrackersViewModel.FilterType, allFilters: [TrackersViewModel.FilterType]) {
        self.currentFilter = currentFilter
        self.filters = allFilters
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        let openEvent = [
            "event": "open",
            "screen": "Filter"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: openEvent)
        print("Analytics: \(openEvent)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let closeEvent = [
            "event": "close",
            "screen": "Filter"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: closeEvent)
        print("Analytics: \(closeEvent)")
    }

    // MARK: - Private Methods
    private func setupUI() {
        title = NSLocalizedString("Фильтры", comment: "")
        view.backgroundColor = .ypWhiteDayNight
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorColor = .ypGray
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDataSource
extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        let filter = filters[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = filter.title
        cell.contentConfiguration = content
        cell.accessoryType = .none
        cell.tintColor = .ypBlue
        if currentFilter == filter && filter.shouldShowCheckmark {
            cell.accessoryType = .checkmark
        }
        cell.backgroundColor = .ypBackground
        cell.selectionStyle = .default
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedFilter = filters[indexPath.row]
        let filterEvent = [
            "event": "click",
            "screen": "Filter",
            "item": "filter_selected"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: filterEvent)
        print("Analytics: \(filterEvent)")
        delegate?.filterViewController(self, didSelect: selectedFilter)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
