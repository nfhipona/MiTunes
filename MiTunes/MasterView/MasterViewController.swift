//
//  MasterViewController.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/14/24.
//

import UIKit
import Combine

class MasterViewController: UIViewController {
    private let viewModel: MasterViewModel

    private let loadingView: LoadingView = {
        return LoadingView(frame: .zero).translatesAutoresizingMask()
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
        setupBindings()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.loadSearch(query: "start")
    }
}

private
extension MasterViewController {
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(loadingView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func setupBindings() {
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
    }

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
}

