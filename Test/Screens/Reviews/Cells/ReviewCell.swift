import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {
    
    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)
    
    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Полное имя пользователя
    let fullName: NSAttributedString
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Максимальное отображаемое количество строк текста. По умолчанию 3.
    var maxLines = 3
    /// Время создания отзыва.
    let created: NSAttributedString
    /// Изображение рейтинга (звезды)
    let ratingImage: UIImage
    /// Изображение аватара пользователя
    let avatarImage: UIImage?
    /// Ссылка на аватар пользователя
    let avatarURL: String?
    /// Массив URL фотографий
    let photoURLs: [String]?
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: ((UUID) -> Void)?
    
    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()
    
}

///  Конфигурация для ячейки-счетчика
struct CounterCellConfig: TableCellConfig {
    static let reuseId = String(describing: CounterCellConfig.self)
    let count: Int
    
    func update(cell: UITableViewCell) {
        cell.textLabel?.text = count.formattedReviewsString()
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    func height(with size: CGSize) -> CGFloat { 44 }
}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {
    
    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        cell.reviewerFullNameLabel.attributedText = fullName
        cell.ratingImageView.image = ratingImage
        cell.avatarImageView.image = UIImage(named: Constants.avatarPlaceholder.value)
        if let avatarURL, let url = URL(string: avatarURL) {
            ImageProvider.shared.loadImage(from: url) { image in
                cell.avatarImageView.image = image ?? UIImage(named: Constants.avatarPlaceholder.value)
            }
        }
        cell.setupPhotosCollectionView(with: photoURLs)
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        cell.createdLabel.attributedText = created
        cell.config = self
    }
    
    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }
    
}

// MARK: - Private

private extension ReviewCellConfig {
    
    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)
    
}

// MARK: - Cell

final class ReviewCell: UITableViewCell {
    
    fileprivate var config: Config?
    
    fileprivate let avatarImageView = UIImageView()
    fileprivate let reviewerFullNameLabel = UILabel()
    fileprivate let ratingImageView = UIImageView()
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()
    fileprivate let photosCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        avatarImageView.frame = layout.avatarImageViewFrame
        reviewerFullNameLabel.frame = layout.fullNameLabelFrame
        ratingImageView.frame = layout.ratingImageViewFrame
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame
        photosCollectionView.frame = layout.photosCollectionViewFrame
    }
    
    @objc func showMoreTapped() {
        guard let config = config else { return }
        config.onTapShowMore?(config.id)
    }
    
    // MARK: - Подготовка к переиспользованию ячейки
    override func prepareForReuse() {
        super.prepareForReuse()
        config = nil
        avatarImageView.image = nil
        reviewerFullNameLabel.attributedText = nil
        ratingImageView.image = nil
        reviewTextLabel.attributedText = nil
        createdLabel.attributedText = nil
        photosCollectionView.isHidden = true
    }
    // Метод для настройки коллекции фотографий
    func setupPhotosCollectionView(with photoURLs: [String]?) {
        if let urls = photoURLs, !urls.isEmpty {
            photosCollectionView.isHidden = false
            photosCollectionView.reloadData()
        } else {
            photosCollectionView.isHidden = true
        }
    }
}

// MARK: - Private

private extension ReviewCell {
    
    func setupCell() {
        setupAvatarImageView()
        setupReviewerFullNameLabel()
        setupRatingImageView()
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
        setupPhotosCollectionView()
    }
    
    func setupAvatarImageView() {
        contentView.addSubview(avatarImageView)
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = Layout.avatarCornerRadius
    }
    
    func setupReviewerFullNameLabel() {
        contentView.addSubview(reviewerFullNameLabel)
    }
    
    func setupRatingImageView() {
        contentView.addSubview(ratingImageView)
        ratingImageView.contentMode = .scaleAspectFit
    }
    
    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }
    
    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }
    
    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
        showMoreButton.addTarget(self, action: #selector(showMoreTapped), for: .touchUpInside)
    }
    
    func setupPhotosCollectionView() {
        contentView.addSubview(photosCollectionView)
        
        guard let layout = photosCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 55.0, height: 66.0)
        layout.minimumInteritemSpacing = 8.0
        layout.minimumLineSpacing = 8.0
        
        photosCollectionView.backgroundColor = .clear
        photosCollectionView.showsHorizontalScrollIndicator = false
        photosCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        photosCollectionView.isHidden = true
    }
    
}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {
    
    // MARK: - Размеры
    
    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0
    
    private static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let showMoreButtonSize = Config.showMoreText.size()
    
    // MARK: - Фреймы
    
    private(set) var avatarImageViewFrame = CGRect.zero
    private(set) var fullNameLabelFrame = CGRect.zero
    private(set) var ratingImageViewFrame = CGRect.zero
    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero
    private(set) var photosCollectionViewFrame = CGRect.zero
    
    // MARK: - Отступы
    
    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)
    
    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing = 10.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing = 10.0
    /// Горизонтальные отступы между фото.
    private let photosSpacing = 8.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing = 6.0
    
    // MARK: - Расчёт фреймов и высоты ячейки
    
    /// Возвращает высоту ячейки с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let contentWidth = maxWidth - insets.left - insets.right
        var currentY = insets.top
        
        // Расчет позиций элементов сверху вниз
        layoutAvatarAndUserInfo(config: config, contentWidth: contentWidth, startY: &currentY)
        layoutRating(config: config, startY: &currentY)
        layoutPhotos(config: config, contentWidth: contentWidth, startY: &currentY)
        layoutReviewText(config: config, contentWidth: contentWidth, startY: &currentY)
        layoutShowMoreButton(config: config, startY: &currentY)
        layoutCreatedDate(config: config, contentWidth: contentWidth, startY: &currentY)
        
        // Возвращаем итоговую высоту с учетом нижнего отступа
        return currentY + insets.bottom
    }

    // MARK: - Layout Components

    /// Расположение аватара и информации о пользователе
    private func layoutAvatarAndUserInfo(config: Config, contentWidth: CGFloat, startY: inout CGFloat) {
        // Расчет фрейма для аватара
        avatarImageViewFrame = CGRect(
            origin: CGPoint(x: insets.left, y: startY),
            size: Self.avatarSize
        )
        
        // Доступная ширина для имени пользователя
        let nameWidth = contentWidth - Self.avatarSize.width - avatarToUsernameSpacing
        
        // Расчет фрейма для имени пользователя (справа от аватара)
        let nameX = avatarImageViewFrame.maxX + avatarToUsernameSpacing
        let nameSize = config.fullName.boundingRect(width: nameWidth).size
        
        fullNameLabelFrame = CGRect(
            origin: CGPoint(x: nameX, y: startY),
            size: nameSize
        )
        
        // Обновляем Y-координату для следующего элемента
        startY = fullNameLabelFrame.maxY + usernameToRatingSpacing
    }

    /// Расположение рейтинга (звезд)
    private func layoutRating(config: Config, startY: inout CGFloat) {
        ratingImageViewFrame = CGRect(
            origin: CGPoint(x: fullNameLabelFrame.minX, y: startY),
            size: config.ratingImage.size
        )
        
        // Обновляем Y-координату для следующего элемента
        // Не увеличиваем startY, так как это будет сделано в методах layoutPhotos или layoutReviewText
    }

    /// Расположение фотографий, если они есть
    private func layoutPhotos(config: Config, contentWidth: CGFloat, startY: inout CGFloat) {
        if let photoURLs = config.photoURLs, !photoURLs.isEmpty {
            // Добавляем отступ от рейтинга до фотографий
            startY = ratingImageViewFrame.maxY + ratingToPhotosSpacing
            
            // Расчет фрейма для коллекции фотографий
            let photoHeight = Self.photoSize.height
            photosCollectionViewFrame = CGRect(
                origin: CGPoint(x: fullNameLabelFrame.minX, y: startY),
                size: CGSize(width: contentWidth, height: photoHeight)
            )
            
            // Обновляем Y-координату для следующего элемента
            startY = photosCollectionViewFrame.maxY + photosToTextSpacing
        } else {
            photosCollectionViewFrame = .zero
            
            // Если фотографий нет, используем другой отступ от рейтинга до текста
            startY = ratingImageViewFrame.maxY + ratingToTextSpacing
        }
    }

    /// Расположение текста отзыва
    private func layoutReviewText(config: Config, contentWidth: CGFloat, startY: inout CGFloat) {
        if !config.reviewText.isEmpty() {
            // Правильный расчет ширины текста
            let textWidth = contentWidth - avatarImageViewFrame.width - avatarToUsernameSpacing
            
            // Расчет высоты текста с учетом ограничения по количеству строк
            let lineHeight = config.reviewText.font()?.lineHeight ?? 0
            let maxAllowedHeight = config.maxLines != 0 ? lineHeight * CGFloat(config.maxLines) : .greatestFiniteMagnitude
            
            let textSize = config.reviewText.boundingRect(width: textWidth, height: maxAllowedHeight).size
            
            reviewTextLabelFrame = CGRect(
                origin: CGPoint(x: fullNameLabelFrame.minX, y: startY),
                size: textSize
            )
            
            // Обновляем Y-координату для следующего элемента
            startY = reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing
        } else {
            reviewTextLabelFrame = .zero
        }
    }

    /// Расчет необходимости и расположения кнопки "Показать полностью..."
    private func layoutShowMoreButton(config: Config, startY: inout CGFloat) {
        // Проверяем, нужна ли кнопка "Показать полностью..."
        let shouldShowButton = shouldShowMoreButton(config: config)
        
        if shouldShowButton {
            showMoreButtonFrame = CGRect(
                origin: CGPoint(x: reviewTextLabelFrame.minX, y: startY),
                size: Self.showMoreButtonSize
            )
            
            // Обновляем Y-координату для следующего элемента
            startY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
        }
    }

    /// Определяет, нужно ли показывать кнопку "Показать полностью..."
    private func shouldShowMoreButton(config: Config) -> Bool {
        if config.maxLines == 0 || config.reviewText.isEmpty() {
            return false
        }
        
        // Высота текста с ограничением по количеству строк
        let lineHeight = config.reviewText.font()?.lineHeight ?? 0
        let currentTextHeight = lineHeight * CGFloat(config.maxLines)
        
        // Полная высота текста без ограничений
        let actualTextHeight = config.reviewText.boundingRect(width: reviewTextLabelFrame.width).size.height
        
        // Показываем кнопку, только если текст не помещается в отведенное количество строк
        return actualTextHeight > currentTextHeight
    }

    /// Расположение даты создания отзыва
    private func layoutCreatedDate(config: Config, contentWidth: CGFloat, startY: inout CGFloat) {
        createdLabelFrame = CGRect(
            origin: CGPoint(x: fullNameLabelFrame.minX, y: startY),
            size: config.created.boundingRect(width: contentWidth).size
        )
        
        // Обновляем Y-координату для следующего элемента
        startY = createdLabelFrame.maxY
    }
    
}

// MARK: - UICollectionViewDataSource

extension ReviewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return config?.photoURLs?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        if let photoURL = config?.photoURLs?[indexPath.item], let url = URL(string: photoURL) {
            cell.loadImage(from: url)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ReviewCell: UICollectionViewDelegate {
    //TO DO сделать обработку нажатия
    
}


// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout
