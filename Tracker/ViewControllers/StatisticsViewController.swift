import UIKit
import SnapKit

// MARK: - StatisticsViewController
final class StatisticsViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: StatisticsViewModelProtocol
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Статистика", comment: "")
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlackDayNight
        return label
    }()
    
    private lazy var placeholderView: PlaceholderView = {
        let view = PlaceholderView()
        view.isHidden = true
        return view
    }()
    
    private lazy var statisticsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .equalSpacing
        stack.isHidden = true
        return stack
    }()
    
    private lazy var bestPeriodCard: StatisticCardView = {
        let card = StatisticCardView(
            title: NSLocalizedString("Лучший период", comment: ""),
            value: "0",
            gradientColors: [UIColor(hex: "FD4C49")!, UIColor(hex: "46E69D")!, UIColor(hex: "007BFA")!]
        )
        return card
    }()
    
    private lazy var perfectDaysCard: StatisticCardView = {
        let card = StatisticCardView(
            title: NSLocalizedString("Идеальные дни", comment: ""),
            value: "0",
            gradientColors: [UIColor(hex: "FD4C49")!, UIColor(hex: "46E69D")!, UIColor(hex: "007BFA")!]
        )
        return card
    }()
    
    private lazy var trackersCompletedCard: StatisticCardView = {
        let card = StatisticCardView(
            title: NSLocalizedString("Трекеров завершено", comment: ""),
            value: "0",
            gradientColors: [UIColor(hex: "FD4C49")!, UIColor(hex: "46E69D")!, UIColor(hex: "007BFA")!]
        )
        return card
    }()
    
    private lazy var averageValueCard: StatisticCardView = {
        let card = StatisticCardView(
            title: NSLocalizedString("Среднее значение", comment: ""),
            value: "0",
            gradientColors: [UIColor(hex: "FD4C49")!, UIColor(hex: "46E69D")!, UIColor(hex: "007BFA")!]
        )
        return card
    }()
    
    // MARK: - Lifecycle
    init(viewModel: StatisticsViewModelProtocol = StatisticsViewModel()) {
        self.viewModel = viewModel
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
        bindViewModel()
        viewModel.loadData()
    
        AnalyticsService.shared.reportEvent(AnalyticsEvent(type: .open, screen: .statistics))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
     
        AnalyticsService.shared.reportEvent(AnalyticsEvent(type: .close, screen: .statistics))
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteDayNight
        view.addSubviews(
            titleLabel,
            placeholderView,
            statisticsStackView
        )
        
        statisticsStackView.addArrangedSubview(bestPeriodCard)
        statisticsStackView.addArrangedSubview(perfectDaysCard)
        statisticsStackView.addArrangedSubview(trackersCompletedCard)
        statisticsStackView.addArrangedSubview(averageValueCard)
       
        placeholderView.configure(
            image: UIImage(named: "placeholderStatistics"),
            text: NSLocalizedString("Анализировать пока нечего", comment: "")
        )
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(16)
        }
        
        placeholderView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        statisticsStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(77)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        [bestPeriodCard, perfectDaysCard, trackersCompletedCard, averageValueCard].forEach { card in
            card.snp.makeConstraints { make in
                make.height.equalTo(90)
            }
        }
    }
    
    private func bindViewModel() {
        viewModel.onDataUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
    }
    
    private func updateUI() {
        let hasData = !viewModel.isEmpty
        
        if hasData {
            placeholderView.isHidden = true
            statisticsStackView.isHidden = false
            
            bestPeriodCard.value = "\(viewModel.bestPeriod)"
            perfectDaysCard.value = "\(viewModel.perfectDays)"
            trackersCompletedCard.value = "\(viewModel.trackersCompleted)"
            averageValueCard.value = "\(viewModel.averageValue)"
        } else {
            placeholderView.isHidden = false
            statisticsStackView.isHidden = true
        }
    }
}
