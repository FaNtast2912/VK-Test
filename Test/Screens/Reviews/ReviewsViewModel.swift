import UIKit

/// Класс, описывающий бизнес-логику экрана отзывов.
final class ReviewsViewModel: NSObject {
    
    /// Замыкание, вызываемое при изменении `state`.
    var onStateChange: ((State) -> Void)?
    
    /// Коллбек, который сообщает ReviewsViewController, какие ячейки вставлять.
    var onItemsInserted: (([IndexPath]) -> Void)?
    
    private var state: State
    private let reviewsProvider: ReviewsProvider
    private let ratingRenderer: RatingRenderer
    private let decoder: JSONDecoder
    
    
    init(
        state: State = State(),
        reviewsProvider: ReviewsProvider = ReviewsProvider(),
        ratingRenderer: RatingRenderer = RatingRenderer(),
        decoder: JSONDecoder = SnakeCaseJSONDecoder()
    ) {
        self.state = state
        self.reviewsProvider = reviewsProvider
        self.ratingRenderer = ratingRenderer
        self.decoder = decoder
    }
    
}

// MARK: - Internal

extension ReviewsViewModel {
    
    typealias State = ReviewsViewModelState
    
    /// Метод получения отзывов.
    func getReviews() {
        guard state.shouldLoad, !state.isLoading else { return }
        
        state.isLoading = true
        onStateChange?(state)
        
        state.shouldLoad = false
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.reviewsProvider.getReviews(offset: self.state.offset) { result in
                DispatchQueue.main.async {
                    self.state.isLoading = false
                    self.gotReviews(result)
                }
            }
        }
    }
    
}

// MARK: - Private

private extension ReviewsViewModel {
    
    /// Метод обработки получения отзывов.
    /// TO DO сейчас я обрабатываю ситуацию когда ко мне приходит больше отзывов чем мне прислал сервер в allReviewsCount
    func gotReviews(_ result: ReviewsProvider.GetReviewsResult) {
        do {
            let data = try result.get()
            let reviews = try decoder.decode(Reviews.self, from: data)
            let allReviewsCount = reviews.count
            
            // Создаем копию текущих элементов для безопасного обновления
            var updatedItems = state.items
            
            // Ограничиваем количество добавляемых отзывов
            let remainingCapacity = allReviewsCount - state.totalCount
            
            var indexPathsToInsert = [IndexPath]()
            
            if remainingCapacity > 0 {
                let limitedReviews = Array(reviews.items.prefix(remainingCapacity))
                let newItems = limitedReviews.map(makeReviewItem)
                
                let startIndex = updatedItems.count
                indexPathsToInsert = (startIndex..<(startIndex + newItems.count)).map { IndexPath(row: $0, section: 0) }
                
                updatedItems.append(contentsOf: newItems)
                state.totalCount += newItems.count
            }
            
            // Обновляем состояние для следующей загрузки
            state.offset += state.limit
            state.shouldLoad = state.totalCount < allReviewsCount
            
            // Добавляем ячейку счетчика только когда загрузили все отзывы и её ещё нет
            if !state.shouldLoad && !updatedItems.contains(where: { $0 is CounterCellConfig }) {
                let counterItem = CounterCellConfig(count: state.totalCount)
                let indexPath = IndexPath(row: updatedItems.count, section: 0)
                
                updatedItems.append(counterItem)
                indexPathsToInsert.append(indexPath)
            }
            
            // Обновляем модель только после полной подготовки
            let finalItems = updatedItems
            
            // Выполняем обновление UI в главном потоке
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // Атомарно обновляем state
                self.state.items = finalItems
                self.state.isLoading = false  // Важно! Устанавливаем isLoading в false
                
                // Только после этого обновляем таблицу
                if !indexPathsToInsert.isEmpty {
                    self.onItemsInserted?(indexPathsToInsert)
                }
                
                // Уведомляем об изменении состояния в любом случае
                self.onStateChange?(self.state)
            }
        } catch {
            state.shouldLoad = true
            state.isLoading = false  // Устанавливаем isLoading в false также при ошибке
            onStateChange?(state)
        }
    }
    
    
    /// Метод, вызываемый при нажатии на кнопку "Показать полностью...".
    /// Снимает ограничение на количество строк текста отзыва (раскрывает текст).
    func showMoreReview(with id: UUID) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        item.maxLines = .zero
        state.items[index] = item
        onStateChange?(state)
    }
    
}

// MARK: - Items



private extension ReviewsViewModel {
    
    typealias ReviewItem = ReviewCellConfig
    
    func makeReviewItem(_ review: Review) -> ReviewItem {
        let fullName = review.fullName.attributed(font: .username)
        let reviewText = review.text.attributed(font: .text)
        let created = review.created.attributed(font: .created, color: .created)
        let ratingImage = ratingRenderer.ratingImage(review.rating)
        let avatarImage = UIImage(named: Constants.avatarPlaceholder.value)
        let avatarURL = review.avatar
        let photoURLs = review.photos
        
        
        let item = ReviewItem(
            fullName: fullName,
            reviewText: reviewText,
            maxLines: 3,
            created: created,
            ratingImage: ratingImage,
            avatarImage: avatarImage,
            avatarURL: avatarURL,
            photoURLs: photoURLs,
            onTapShowMore: { [weak self] id in
                self?.showMoreReview(with: id)
            }
        )
        return item
    }
    
}

// MARK: - UITableViewDataSource

extension ReviewsViewModel: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(state.items.count)
        return state.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let config = state.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: config.reuseId, for: indexPath)
        config.update(cell: cell)
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension ReviewsViewModel: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        state.items[indexPath.row].height(with: tableView.bounds.size)
    }
    
    /// Метод дозапрашивает отзывы, если до конца списка отзывов осталось два с половиной экрана по высоте.
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
            getReviews()
        }
    }
    
    private func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double = 2.5
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }
    
}
