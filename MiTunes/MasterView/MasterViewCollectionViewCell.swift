//
//  MasterViewCollectionViewCell.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/15/24.
//

import Foundation
import UIKit

final class MasterViewCollectionViewCell: UICollectionViewCell {
    static var canvasSize: CGSize = {
        let screenHeight = [
            Constants.padding,
            Constants.imageSize.height,
            Constants.padding,
            Constants.nameLabelHeight,
            Constants.padding,
            Constants.priceLabelHeight,
            Constants.padding4,
            Constants.genreLabelHeight,
            Constants.padding
        ].reduce(0, { partialResult, next in
            partialResult + next
        })

        return CGSize(
            width: Constants.screenWidth,
            height: screenHeight
        )
    }()

    private enum Constants {
        static let padding: CGFloat = 8
        static let padding4: CGFloat = 4

        static let screenWidth: CGFloat = {
            /// left - mid - right
            let canvasPadding = padding * 3
            let screenWidth = (UIScreen.main.bounds.width - canvasPadding) / 2
            return screenWidth
        }()

        static let imageSize = {
            let imageWidth = screenWidth - padding * 2
            return CGSize(width: imageWidth, height: imageWidth)
        }()

        static let nameLabelHeight: CGFloat = 40
        static let priceLabelHeight: CGFloat = 16
        static let genreLabelHeight: CGFloat = 16
    }

    static let identifier: String = UUID().uuidString

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
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 2
        return label.translatesAutoresizingMask()
    }()

    private let priceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label.translatesAutoresizingMask()
    }()

    private let genreLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label.translatesAutoresizingMask()
    }()

    private var model: MasterViewModelItem?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setModel(_ model: MasterViewModelItem) {
        self.model = model

        let media = model.media
        nameLabel.text = media.trackName
        priceLabel.text = media.trackPrice.currency
        genreLabel.text = media.primaryGenreName
    }
}

private
extension MasterViewCollectionViewCell {
    func setupViews() {
        contentView.addSubviews([
            imageView,
            nameLabel,
            priceLabel,
            genreLabel
        ])
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.padding),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.padding),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.padding),
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageSize.width),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageSize.height)
        ])

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.padding),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.padding),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.padding),
            nameLabel.heightAnchor.constraint(equalToConstant: Constants.nameLabelHeight)
        ])

        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Constants.padding),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.padding),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.padding),
            priceLabel.heightAnchor.constraint(equalToConstant: Constants.priceLabelHeight)
        ])

        NSLayoutConstraint.activate([
            genreLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: Constants.padding4),
            genreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.padding),
            genreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.padding),
            genreLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.padding),
            genreLabel.heightAnchor.constraint(equalToConstant: Constants.genreLabelHeight)
        ])
    }
}
