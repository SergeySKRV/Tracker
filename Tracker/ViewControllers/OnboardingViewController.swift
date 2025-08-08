import UIKit
import SnapKit

// MARK: - OnboardingViewController
final class OnboardingViewController: UIViewController {
    
    // MARK: - Properties
    private var pageViewController: UIPageViewController!
    private var pages: [UIViewController] = []
    private let doneButton = UIButton(type: .system)
    private let pageControl = UIPageControl()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPages()
        setupPageViewController()
        setupUI()
        setupConstraints()
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
        view.backgroundColor = .ypWhiteDay
        
        doneButton.setTitle(NSLocalizedString("Вот это технологии!", comment: ""), for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        doneButton.setTitleColor(.ypWhiteDay, for: .normal)
        doneButton.backgroundColor = .ypBlackDay
        doneButton.layer.cornerRadius = 16
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        view.addSubview(doneButton)
        
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .ypGray
        pageControl.currentPageIndicatorTintColor = .ypBlackDay
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
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true)
    }
}

// MARK: - Status Bar
extension OnboardingViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        return index == 0 ? pages.last : pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        return index == pages.count - 1 ? pages.first : pages[index + 1]
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
        }
    }
}
