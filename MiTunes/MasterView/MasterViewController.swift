//
//  MasterViewController.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/14/24.
//

import UIKit
import Combine

final class MasterViewController: UIViewController {
    private enum Constants {
        static let spacing: CGFloat = 8
    }

    private let viewModel: MasterViewModel

    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = MasterViewCollectionViewCell.canvasSize
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = Constants.spacing
        flowLayout.minimumLineSpacing = Constants.spacing
        flowLayout.sectionInset = UIEdgeInsets(
            top: Constants.spacing,
            left: Constants.spacing,
            bottom: Constants.spacing,
            right: Constants.spacing
        )

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: flowLayout
        )
        return collectionView.translatesAutoresizingMask()
    }()

    private let loadingView: LoadingView = {
        return LoadingView(frame: .zero).translatesAutoresizingMask()
    }()

    private lazy var dataSource: MasterViewDataSource = {
        makeDataSource()
    }()

    init(viewModel: MasterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .main)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setupViews()
        setupCollectionViews()
        setupBindings()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.preLoadData()
    }
}

// MARK: - Setup

private
extension MasterViewController {
    func setupViews() {
        view.backgroundColor = .white
        view.addSubviews([
            collectionView,
            loadingView
        ])
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func setupCollectionViews() {
        collectionView.register(MasterViewCollectionViewCell.self, forCellWithReuseIdentifier: MasterViewCollectionViewCell.identifier)
    }

    func setupBindings() {
        collectionView.dataSource = makeDataSource()

        viewModel
            .loadingNotifier
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .startLoading:
                    loadingView.startLoading()
                case .stopLoading:
                    loadingView.stopLoading()
                }
            }
            .store(in: &viewModel.cancellables)

        viewModel
            .errorNotifier
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case let .showError(title, message, action):
                    showAlert(
                        title: title,
                        message: message,
                        action: action
                    )
                }
            }
            .store(in: &viewModel.cancellables)

        viewModel
            .updateNotifier
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                guard let self else { return }
                dataSource.apply(snapshot)
            }
            .store(in: &viewModel.cancellables)
    }
}

// MARK: - Methods

private
extension MasterViewController {
    func showAlert(
        title: String?,
        message: String?,
        action: (() -> Void)?
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alertController.addAction(
            UIAlertAction(
                title: "OK",
                style: .default,
                handler: { _ in
                    action?()
                }
            )
        )

        present(alertController, animated: true)
    }

    func makeDataSource() -> MasterViewDataSource {
        MasterViewDataSource(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            switch item.sectionType {
            case .main:
                guard
                    let customCell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: MasterViewCollectionViewCell.identifier,
                        for: indexPath
                    ) as? MasterViewCollectionViewCell
                else { return UICollectionViewCell() }
                customCell.setModel(item)
                return customCell
            }
        }
    }
}
