//
//  MasterViewFavoriteCollectionViewCell.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/17/24.
//

import Foundation
import UIKit

extension MasterViewFavoriteCollectionViewCell {
    static var canvasSize = CGSize(width: 100, height: 100)

    private enum Constants {
        static let padding: CGFloat = 8

        static let imageSize = {
            let imageWidth = canvasSize.width - padding * 2
            return CGSize(width: imageWidth, height: imageWidth)
        }()
    }
}

final class MasterViewFavoriteCollectionViewCell: UICollectionViewCell {
    static let identifier: String = UUID().uuidString

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.imageSize.height / 2
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView.translatesAutoresizingMask()
    }()

    private var model: MasterViewModelFavoriteItem?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setModel(_ model: MasterViewModelFavoriteItem) {
        self.model = model

        let media = model.media
        imageView.setImageURL(media.artworkUrl100.unwrapped)
    }
}

// MARK: - Setup

private
extension MasterViewFavoriteCollectionViewCell {
    func setupViews() {
        contentView.addSubview(imageView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.padding),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.padding),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.padding),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.padding),
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageSize.width),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageSize.height)
        ])
    }
}
