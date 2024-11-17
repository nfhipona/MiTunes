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
    private var masterData: [MasterViewModelItem] = []
    private var favoriteData: [MasterViewModelFavoriteItem] = []

    var cancellables = Set<AnyCancellable>()
    let loadingNotifier = PassthroughSubject<LoadingState, Never>()
    let errorNotifier = PassthroughSubject<ErrorState, Never>()
    let updateNotifier = PassthroughSubject<MasterViewSnapshot, Never>()
    let updateFavoriteNotifier = PassthroughSubject<(Bool, MasterViewFavoriteSnapshot), Never>()
    let navigateNotifier = PassthroughSubject<Media, Never>()

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
            debugLog("Search Result:", result)
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
                debugLog("CoreDataStack.shared.saveContext:", error)
            }
            loadingNotifier.send(.stopLoading)
        }
    }

    func makeSnapshot(media: [Media]) {
        let mapped = media.map {
            MasterViewModelItem(
                sectionType: .main,
                media: $0
            )
        }
        let updateNotifiers = mapped.map { $0.updateNotifier }
        handleUpdateNotifier(updateNotifiers: updateNotifiers)

        masterData = mapped
        var snapshot = MasterViewSnapshot()
        snapshot.appendSections(MasterViewSectionType.allCases)
        snapshot.appendItems(mapped, toSection: .main)
        updateNotifier.send(snapshot)
    }

    func makeFavoriteSnapshot(media: [Media]) {
        let mapped = media.map {
            MasterViewModelFavoriteItem(media: $0)
        }
        favoriteData = mapped
        var snapshot = MasterViewFavoriteSnapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(mapped, toSection: 0)
        updateFavoriteNotifier.send((!favoriteData.isEmpty, snapshot))
    }

    func handleUpdateNotifier(updateNotifiers: [MasterViewModelItem.UpdateNotifier]) {
        Publishers
            .MergeMany(updateNotifiers)
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .favorite:
                    reloadFavorites()
                }
            }
            .store(in: &cancellables)
    }
}

// Mark: - Methods

extension MasterViewModel {
    func preLoadData() {
        loadingNotifier.send(.startLoading)
        let media = CoreDataStack.shared.fetchAllMedia()
        debugLog("Master Data: \(media.count)")
        reloadFavorites()

        if media.isEmpty {
            loadSearch(query: "star")
        } else {
            makeSnapshot(media: media)
            loadingNotifier.send(.stopLoading)
        }
    }

    func reloadFavorites() {
        let favoriteMedia = CoreDataStack.shared.fetchAllFavoriteMedia()
        makeFavoriteSnapshot(media: favoriteMedia)
        debugLog("Favorite Data: \(favoriteMedia.count)")
    }

    func didSelectItem(at indexPath: IndexPath)  {
        guard indexPath.row < masterData.count else { return }
        let item = masterData[indexPath.row]
        navigateNotifier.send(item.media)
    }

    func didSelectFavoriteItem(at indexPath: IndexPath)  {
        guard indexPath.row < favoriteData.count else { return }
        let item = favoriteData[indexPath.row]
        navigateNotifier.send(item.media)
    }
}
