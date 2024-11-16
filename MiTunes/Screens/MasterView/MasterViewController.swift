//
//  MasterViewController.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/14/24.
//

import Combine
import UIKit

extension MasterViewController {
    private enum Constants {
        static let spacing: CGFloat = 8
        static let favoriteCollectionViewHeight: CGFloat = 100
    }
}

final class MasterViewController: UIViewController {
    private let viewModel: MasterViewModel

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = self
        searchBar.placeholder = "Search media here ..."
        searchBar.barStyle = .default
        searchBar.showsCancelButton = true
        return searchBar.translatesAutoresizingMask()
    }()

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

    private lazy var collectionViewTopConstant: NSLayoutConstraint = {
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
    }()

    private let favoriteCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = MasterViewFavoriteCollectionViewCell.canvasSize
        flowLayout.scrollDirection = .horizontal
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
        collectionView.isHidden = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView.translatesAutoresizingMask()
    }()

    private let loadingView: LoadingView = {
        return LoadingView(frame: .zero).translatesAutoresizingMask()
    }()

    private lazy var dataSource: MasterViewDataSource = {
        makeDataSource()
    }()

    private lazy var favoriteDataSource: MasterViewFavoriteDataSource = {
        makeFavoriteDataSource()
    }()

    private var keyboardTimer: Timer?

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

        setupNavigation()
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
    func setupNavigation() {
        navigationItem.titleView = searchBar
        navigationItem.hidesSearchBarWhenScrolling = true
    }

    func setupViews() {
        view.backgroundColor = .white
        collectionView.delegate = self
        favoriteCollectionView.delegate = self

        view.addSubviews([
            favoriteCollectionView,
            collectionView,
            loadingView
        ])

        favoriteCollectionView.layer.borderWidth = 1
        favoriteCollectionView.layer.borderColor = UIColor.lightGray.cgColor
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            favoriteCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            favoriteCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            favoriteCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            favoriteCollectionView.heightAnchor.constraint(equalToConstant: Constants.favoriteCollectionViewHeight)
        ])

        NSLayoutConstraint.activate([
            collectionViewTopConstant,
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
        favoriteCollectionView.register(MasterViewFavoriteCollectionViewCell.self, forCellWithReuseIdentifier: MasterViewFavoriteCollectionViewCell.identifier)
    }

    func setupBindings() {
        collectionView.dataSource = dataSource
        favoriteCollectionView.dataSource = favoriteDataSource

        viewModel
            .loadingNotifier
            .receive(on: DispatchQueue.main)
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
            .receive(on: DispatchQueue.main)
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

        viewModel
            .updateFavoriteNotifier
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (hasFavorites, snapshot) in
                guard let self else { return }
                updateCollectionViewConstraints(hasFavorites: hasFavorites)
                favoriteCollectionView.isHidden = !hasFavorites
                favoriteDataSource.apply(snapshot)
            }
            .store(in: &viewModel.cancellables)

        viewModel
            .navigateNotifier
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                guard let self else { return }
                navigateToDetailPage(with: item)
            }
            .store(in: &viewModel.cancellables)
    }

    func updateCollectionViewConstraints(hasFavorites: Bool) {
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self else { return }
            collectionViewTopConstant.constant = hasFavorites ? Constants.favoriteCollectionViewHeight : 0
            view.layoutSubviews()
        }
    }
}

// MARK: - UICollectionViewDelegate

extension MasterViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == favoriteCollectionView {
            viewModel.didSelectFavoriteItem(at: indexPath)
        } else {
            viewModel.didSelectItem(at: indexPath)
        }
    }
}

// MARK: - UISearchBarDelegate

extension MasterViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        keyboardTimer?.invalidate()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        keyboardTimer?.invalidate()
        keyboardTimer = Timer.scheduledTimer(
            withTimeInterval: 2,
            repeats: false,
            block: { [weak self] timer in
                timer.invalidate()
                guard let self,
                      let query = searchBar.text,
                      query.count > 3
                else { return }
                viewModel.loadSearch(query: query)
            }
        )
        let query = searchBar.text.unwrapped
        if query.isEmpty {
            viewModel.preLoadData()
        } else if query.count > 3 {
            keyboardTimer?.fireDate = Date().addingTimeInterval(1)
        }

    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        keyboardTimer?.invalidate()
        guard let query = searchBar.text, query.count > 3 else { return }
        viewModel.loadSearch(query: query)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        keyboardTimer?.invalidate()
        viewModel.preLoadData()
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

    func makeFavoriteDataSource() -> MasterViewFavoriteDataSource {
        MasterViewFavoriteDataSource(
            collectionView: favoriteCollectionView
        ) { collectionView, indexPath, item in
            guard
                let customCell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MasterViewFavoriteCollectionViewCell.identifier,
                    for: indexPath
                ) as? MasterViewFavoriteCollectionViewCell
            else { return UICollectionViewCell() }
            customCell.setModel(item)
            return customCell
        }
    }

    func navigateToDetailPage(with media: Media) {
        let viewModel = DetailViewModel(media: media)
        let detailViewController = DetailViewController(viewModel: viewModel)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
