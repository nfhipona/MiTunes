//
//  DetailViewController.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/15/24.
//

import Combine
import UIKit

extension DetailViewController {
    private enum Constants {
        static let padding8: CGFloat = 8
        static let padding24: CGFloat = 24

        static let imageSize = {
            /// left - right
            let canvasPadding = padding24 * 2
            let imageWidth = UIScreen.main.bounds.width - canvasPadding
            return CGSize(width: imageWidth, height: imageWidth)
        }()

        static let nameLabelHeight: CGFloat = 24
        static let trackIdLabelHeight: CGFloat = 18
        static let artistNameLabelHeight: CGFloat = 18
        static let priceLabelHeight: CGFloat = 18
        static let genreLabelHeight: CGFloat = 16
        static let shortDescriptionLabelHeight: CGFloat = 16
        static let longDescriptionLabelHeight: CGFloat = 16
        static let favoriteButtonSize = CGSize(width: 40, height: 40)
    }
}

final class DetailViewController: UIViewController {
    private let viewModel: DetailViewModel

    private lazy var titleView: UIView = {
        let lastVisitText = viewModel
            .media
            .lastVisitAt?
            .readableDisplay

        let dateLabel = UILabel(frame: .zero)
            .translatesAutoresizingMask()
        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dateLabel.text = lastVisitText.unwrapped.isEmpty ? "" : "Last Visit: \(lastVisitText.unwrapped)"

        let titleView = UIView(frame: .zero)
        titleView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: titleView.topAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor)
        ])

        return titleView.translatesAutoresizingMask()
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView.translatesAutoresizingMask()
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView.translatesAutoresizingMask()
    }()

    private let nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 0
        return label.translatesAutoresizingMask()
    }()

    private let trackIdLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label.translatesAutoresizingMask()
    }()

    private let artistNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        return label.translatesAutoresizingMask()
    }()

    private let genreLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label.translatesAutoresizingMask()
    }()

    private let priceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label.translatesAutoresizingMask()
    }()

    private let shortDescriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.numberOfLines = 0
        label.textAlignment = .justified
        return label.translatesAutoresizingMask()
    }()

    private let longDescriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .justified
        return label.translatesAutoresizingMask()
    }()

    private lazy var longDescriptionLabelTopConstraint: NSLayoutConstraint = {
        longDescriptionLabel.topAnchor.constraint(equalTo: shortDescriptionLabel.bottomAnchor, constant: Constants.padding8)
    }()

    private let favoriteButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        let activeImage = UIImage(systemName: "heart.fill")?
            .withRenderingMode(.alwaysTemplate)
        activeImage?.withTintColor(.blue)
        button.setImage(activeImage, for: .selected)
        button.contentMode = .scaleAspectFit
        return button.translatesAutoresizingMask()
    }()

    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupView()
        setupConstraints()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadContent()
    }
}

// MARK: - Setup

private
extension DetailViewController {
    func setupNavigation() {
        navigationItem.titleView = titleView
    }

    func setupView() {
        view.backgroundColor = .white
        view.addSubview(scrollView)

        scrollView.addSubviews([
            imageView,
            nameLabel,
            trackIdLabel,
            artistNameLabel,
            genreLabel,
            priceLabel,
            shortDescriptionLabel,
            longDescriptionLabel,
            favoriteButton
        ])
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.padding24),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.padding24),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.padding24),
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageSize.width),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageSize.height)
        ])

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.padding24),
            nameLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.padding24),
            nameLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.padding24),
            nameLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.nameLabelHeight)
        ])

        NSLayoutConstraint.activate([
            trackIdLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Constants.padding24),
            trackIdLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.padding24),
            trackIdLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: -Constants.padding24),
            trackIdLabel.heightAnchor.constraint(equalToConstant: Constants.trackIdLabelHeight)
        ])

        NSLayoutConstraint.activate([
            artistNameLabel.topAnchor.constraint(equalTo: trackIdLabel.bottomAnchor, constant: Constants.padding8),
            artistNameLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.padding24),
            artistNameLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.padding24),
            artistNameLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.artistNameLabelHeight),
        ])

        NSLayoutConstraint.activate([
            genreLabel.topAnchor.constraint(equalTo: artistNameLabel.bottomAnchor, constant: Constants.padding8),
            genreLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.padding24),
            genreLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: -Constants.padding24),
            genreLabel.heightAnchor.constraint(equalToConstant: Constants.genreLabelHeight)
        ])

        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: genreLabel.topAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.padding24),
            priceLabel.heightAnchor.constraint(equalToConstant: Constants.priceLabelHeight)
        ])

        NSLayoutConstraint.activate([
            shortDescriptionLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: Constants.padding24),
            shortDescriptionLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.padding24),
            shortDescriptionLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.padding24),
            shortDescriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.shortDescriptionLabelHeight)
        ])

        NSLayoutConstraint.activate([
            longDescriptionLabel.topAnchor.constraint(greaterThanOrEqualTo: priceLabel.bottomAnchor, constant: Constants.padding24),
            longDescriptionLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.padding24),
            longDescriptionLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.padding24),
            longDescriptionLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -Constants.padding24),
            longDescriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.longDescriptionLabelHeight)
        ])

        NSLayoutConstraint.activate([
            favoriteButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -Constants.padding8),
            favoriteButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -Constants.padding8),
            favoriteButton.widthAnchor.constraint(equalToConstant: Constants.favoriteButtonSize.width),
            favoriteButton.heightAnchor.constraint(equalToConstant: Constants.favoriteButtonSize.height)
        ])
    }

    func setupBindings(){
        favoriteButton.addTarget(self, action: #selector(favoriteButtonAction), for: .touchUpInside)
    }
}

// MARK: - Methods

private
extension DetailViewController {
    func loadContent() {
        let media = viewModel.media
        nameLabel.text = media.trackName
        trackIdLabel.text = "Track ID: \(media.trackId)"
        artistNameLabel.text = "Artist Name: \(media.artistName.unwrapped)"
        priceLabel.text = "Price: \(media.trackPrice.currency)"
        genreLabel.text = "Genre: \(media.primaryGenreName.unwrapped)"
        shortDescriptionLabel.text = media.mediaShortDescription
        longDescriptionLabel.text = media.mediaLongDescription
        favoriteButton.isSelected = media.isFavorite

        longDescriptionLabelTopConstraint.isActive = !media.mediaShortDescription.unwrapped.isEmpty

        let placeholderImage = UIImage(systemName: "movieclapper.fill")
        if let imageURL = URL(string: media.artworkUrl100.unwrapped) {
            imageView.af.setImage(
                withURL: imageURL,
                placeholderImage: placeholderImage
            )
        } else {
            imageView.image = placeholderImage
        }

        CoreDataStack
            .shared
            .setMediaLastVisit(for: media)
    }

    @objc func favoriteButtonAction() {
        let media = viewModel.media
        let isFavorite = !media.isFavorite
        CoreDataStack
            .shared
            .setMediaFavoriteState(
                for: media,
                isFavorite: isFavorite
            )
        favoriteButton.isSelected = isFavorite
    }
}
