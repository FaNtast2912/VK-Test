import UIKit

final class ReviewsViewController: UIViewController {
    
    private lazy var reviewsView = makeReviewsView()
    private lazy var loadingIndicator = makeLoadingIndicator()
    private let viewModel: ReviewsViewModel
    
    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = reviewsView
        title = "Отзывы"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        loadingIndicator.startAnimating()
        viewModel.getReviews()
    }
}

// MARK: - Extension

private extension ReviewsViewController {
    
    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.tableView.delegate = viewModel
        reviewsView.tableView.dataSource = viewModel
        return reviewsView
    }
    
    func makeLoadingIndicator() -> LoadingIndicatorView {
        let loadingIndicator = LoadingIndicatorView(
            dotSize: 10.0,
            dotSpacing: 8.0,
            dotColor: .systemBlue,
            horizontalPadding: 8.0
        )
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        return loadingIndicator
    }
    
    func setupUI() {
        setupLoadingIndicator()
    }
    
    func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.bringSubviewToFront(loadingIndicator)
        loadingIndicator.isHidden = true
    }
    
    func setupViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self = self else { return }
            
            if state.isLoading {
                self.loadingIndicator.startAnimating()
            } else {
                self.loadingIndicator.stopAnimating()
            }
        }
        
        viewModel.onItemsInserted = { [weak self] indexPaths in
            guard let self = self else { return }
            
            self.reviewsView.tableView.performBatchUpdates({
                self.reviewsView.tableView.insertRows(at: indexPaths, with: .automatic)
            })
        }
    }
    
}
