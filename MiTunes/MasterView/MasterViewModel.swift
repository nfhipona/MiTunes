//
//  MasterViewModel.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/14/24.
//

import Foundation
import Combine

extension MasterViewModel {
    enum ErrorState {
        case showError(
            title: String?,
            message: String?,
            action: (() -> Void)?
        )
    }

    enum LoadingState {
        case startLoading
        case stopLoading
    }
}

final class MasterViewModel: ObservableObject {
    private let service: iTunesServiceAPI

    var cancellables = Set<AnyCancellable>()
    let loadingNotifier = PassthroughSubject<LoadingState, Never>()
    let errorNotifier = PassthroughSubject<ErrorState, Never>()

    init(service: iTunesServiceAPI) {
        self.service = service
    }

    func loadSearch(query: String) {
        loadingNotifier.send(.startLoading)
        service.search(
            req: .search(
                queries: [
                    "term": query,
                    "country": "au",
                    "media": "movie"
                ]
            )
        )
        .sink { [weak self] result in
            guard let self else { return }
            switch result {
            case let .failure(error):
                loadingNotifier.send(.stopLoading)
                errorNotifier.send(
                    .showError(
                        title: "Error Alert",
                        message: error.localizedDescription,
                        action: nil
                    )
                )
            default: break
            }
        } receiveValue: { [weak self] result in
            guard let self else { return }
            print("Search Result:", result)
            processResult(result: result)
        }
        .store(in: &cancellables)
    }
}

private
extension MasterViewModel {
    func processResult(result: iTunesSearchResult) {
        let mapped = result.results
            .map {
                CoreDataStack.shared.createMedia(for: $0)
            }
        mapped.forEach {
            CoreDataStack.shared.insert(model: $0)
        }

        CoreDataStack.shared.saveContext { [weak self] error in
            guard let self else { return }
            if let error {
                print("CoreDataStack.shared.saveContext:", error)
            }
            loadingNotifier.send(.stopLoading)
        }
    }
}
