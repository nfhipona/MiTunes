//
//  LoadingView.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/14/24.
//

import Foundation
import UIKit

final class LoadingView: UIView {
    private enum Constants {
        static let iconSize = CGSize(width: 60, height: 60)
        static let iconBottomConstraint: CGFloat = 16
        static let activityIndicatorYConstraint: CGFloat = 8
    }

    private let activityIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.color = .white
        indicatorView.hidesWhenStopped = true
        return indicatorView.translatesAutoresizingMask()
    }()

    private let blurredEffectView: UIVisualEffectView = {
        let effect = UIVisualEffect()
        let blurEffect = UIBlurEffect(style: .dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        return blurredEffectView.translatesAutoresizingMask()
    }()

    private let musicIconView: UIImageView = {
        guard
            let image = UIImage(systemName: "popcorn.fill")?
                .withRenderingMode(.alwaysTemplate)
        else { fatalError("Missing symbol ...") }
        image.withTintColor(.blue)

        let imageView = UIImageView(frame: .zero)
        imageView.setSymbolImage(image, contentTransition: .automatic)
        imageView.addSymbolEffect(.bounce, options: .repeating)

        return imageView.translatesAutoresizingMask()
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        isHidden = true
        alpha = 0.0
        backgroundColor = .clear

        addSubviews([
            blurredEffectView,
            musicIconView,
            activityIndicatorView
        ])
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            blurredEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurredEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurredEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurredEffectView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            musicIconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            musicIconView.bottomAnchor.constraint(equalTo: activityIndicatorView.topAnchor, constant: -Constants.iconBottomConstraint),

            musicIconView.widthAnchor.constraint(equalToConstant: Constants.iconSize.width),
            musicIconView.heightAnchor.constraint(equalToConstant: Constants.iconSize.height)
        ])

        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -Constants.activityIndicatorYConstraint)
        ])
    }
}

extension LoadingView {
    func startLoading() {
        isHidden = true
        alpha = 0.0
        activityIndicatorView.startAnimating()

        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self else { return }
            isHidden = false
            alpha = 1.0
        } completion: { [weak self] _ in
            guard let self else { return }
            isHidden = false
            alpha = 1.0
        }
    }

    func stopLoading() {
        activityIndicatorView.stopAnimating()
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self else { return }
            isHidden = true
            alpha = 0.0
        } completion: { [weak self] _ in
            guard let self else { return }
            isHidden = true
            alpha = 0.0
        }
    }
}
