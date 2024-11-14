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

        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.loadFetch()
    }
}

private
extension MasterViewController {
    private func setupBindings() {
        viewModel
            .loadingNotifier
            .sink { state in
                switch state {
                case .startLoading:
                    break
                case .stopLoading:
                    break
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

    private func showAlert(
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

