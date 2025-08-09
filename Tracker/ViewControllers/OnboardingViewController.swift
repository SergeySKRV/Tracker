import UIKit
import SnapKit
import AppMetricaCore

// MARK: - OnboardingViewController
final class OnboardingViewController: UIViewController {
    
    // MARK: - UI Elements
    private var pageViewController: UIPageViewController!
    private let doneButton = UIButton(type: .system)
    private let pageControl = UIPageControl()
    
    // MARK: - Properties
    private var pages: [UIViewController] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPages()
        setupPageViewController()
        setupUI()
        setupConstraints()

        let openEvent = [
            "event": "open",
            "screen": "Onboarding"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: openEvent)
        print("Analytics: \(openEvent)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let closeEvent = [
            "event": "close",
            "screen": "Onboarding"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: closeEvent)
        print("Analytics: \(closeEvent)")
    }
    
    // MARK: - Override Methods
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    // MARK: - Private Methods
    private func setupPages() {
        let page1 = OnboardingPageViewController(
            imageName: "onboarding1",
            title: NSLocalizedString("Отслеживайте только то, что хотите", comment: "")
        )
        
        let page2 = OnboardingPageViewController(
            imageName: "onboarding2",
            title: NSLocalizedString("Даже если это не литры воды и йога", comment: "")
        )
        
        pages = [page1, page2]
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        if let firstPage = pages.first {
            pageViewController.setViewControllers(
                [firstPage],
                direction: .forward,
                animated: true
            )
        }
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhiteDayNight
        
        doneButton.setTitle(NSLocalizedString("Вот это технологии!", comment: ""), for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        doneButton.setTitleColor(.ypWhiteDayNight, for: .normal)
        doneButton.backgroundColor = .ypBlackDayNight
        doneButton.layer.cornerRadius = 16
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        view.addSubview(doneButton)
        
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .ypGray
        pageControl.currentPageIndicatorTintColor = .ypBlackDayNight
        view.addSubview(pageControl)
    }
    
    private func setupConstraints() {
        pageViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        doneButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-50)
            make.height.equalTo(60)
        }
        
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(doneButton.snp.top).offset(-24)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        let doneEvent = [
            "event": "click",
            "screen": "Onboarding",
            "item": "done"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: doneEvent)
        print("Analytics: \(doneEvent)")
        
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true)
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = index == 0 ? pages.count - 1 : index - 1
   
        let prevEvent = [
            "event": "click",
            "screen": "Onboarding",
            "item": "page_previous"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: prevEvent)
        print("Analytics: \(prevEvent)")
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = index == pages.count - 1 ? 0 : index + 1
    
        let nextEvent = [
            "event": "click",
            "screen": "Onboarding",
            "item": "page_next"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: nextEvent)
        print("Analytics: \(nextEvent)")
        
        return pages[nextIndex]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if let current = pageViewController.viewControllers?.first,
           let index = pages.firstIndex(of: current) {
            pageControl.currentPage = index
            
            if completed {
      
                let pageEvent = [
                    "event": "click",
                    "screen": "Onboarding",
                    "item": "page_changed"
                ]
                AppMetrica.reportEvent(name: "Screen Event", parameters: pageEvent)
                print("Analytics: \(pageEvent)")
            }
        }
    }
}
