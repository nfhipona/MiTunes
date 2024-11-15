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
    let updateNotifier = PassthroughSubject<MasterViewSnapshot, Never>()

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

// Mark: - Helpers

private
extension MasterViewModel {
    func processResult(result: iTunesSearchResult) {
        let mapped = result.results
            .map { CoreDataStack.shared.insertOrUpdateMedia(for: $0) }
        makeSnapshot(media: mapped)

        CoreDataStack.shared.saveContext { [weak self] error in
            guard let self else { return }
            if let error {
                print("CoreDataStack.shared.saveContext:", error)
            }
            loadingNotifier.send(.stopLoading)
        }
    }

    func makeSnapshot(media: [Media]) {
        var snapshot = MasterViewSnapshot()
        let masterData = media.map {
            MasterViewModelItem(
                sectionType: .main,
                media: $0
            )
        }
        snapshot.appendSections(MasterViewSectionType.allCases)
        snapshot.appendItems(masterData, toSection: .main)
        updateNotifier.send(snapshot)
    }
}

// Mark: - Methods

extension MasterViewModel {
    func preLoadData() {
        loadingNotifier.send(.startLoading)
        let media = CoreDataStack.shared.fetchAllMedia()
        print("media count:", media.count)
        
        if media.isEmpty {
            loadSearch(query: "star")
        } else {
            makeSnapshot(media: media)
            loadingNotifier.send(.stopLoading)
        }
    }
}
