/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2024 Infomaniak Network SA

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See them
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import InfomaniakCore
import InfomaniakCoreCommonUI
import InfomaniakCoreSwiftUI
import InfomaniakDI
import SafariServices
import STCore
import STResources
import STRootTransferView
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI
import VersionChecker

public struct MainView: View {
    @LazyInjectService private var injection: SwissTransferInjection
    @LazyInjectService private var matomo: MatomoUtils
    @LazyInjectService private var reviewManager: ReviewManageable

    @Environment(\.isCompactWindow) private var isCompactWindow
    @Environment(\.openURL) private var openURL

    @EnvironmentObject private var mainViewState: MainViewState
    @EnvironmentObject private var universalLinksState: UniversalLinksState
    @EnvironmentObject private var notificationCenterDelegate: NotificationCenterDelegate
    @Environment(\.openURL) private var openURL

    private let reviewTriggerCount = 2

    public init() {}

    public var body: some View {
        ZStack {
            if isCompactWindow {
                STTabView()
            } else {
                STSplitView()
            }
        }
        .sceneLifecycle(willEnterForeground: willEnterForeground)
        .environmentObject(mainViewState.transferManager)
        .onAppear {
            if UserDefaults.shared.transferCount == reviewTriggerCount && !UserDefaults.shared.hasReviewedApp {
                mainViewState.isShowingReviewAlert = true
            }
        }
        .onChange(of: universalLinksState.linkedTransfer) { linkedTransfer in
            guard let linkedTransfer else { return }

            mainViewState.handleDeepLink(linkedTransfer)
            universalLinksState.linkedTransfer = nil
        }
        .onChange(of: universalLinksState.linkedImportUUID) { linkedLocalSessionUUID in
            guard let linkedLocalSessionUUID else { return }

            mainViewState.newTransferContainer = NewTransferContainer(localSessionUUID: linkedLocalSessionUUID)
            universalLinksState.linkedImportUUID = nil
        }
        .onChange(of: notificationCenterDelegate.tappedTransfer) { tappedTransfer in
            guard let tappedTransfer else { return }

            mainViewState.selectedTransfer = .transfer(tappedTransfer)
        }
        .task(id: isCompactWindow) {
            mainViewState.isSplitView = !isCompactWindow
        }
        .fullScreenCover(item: $mainViewState.newTransferContainer) { container in
            switch container.content {
            case .importedItems(let importedItems):
                RootTransferView(initialItems: importedItems)
            case .shareExtensionContinuing(let localSessionUUID):
                RootTransferView(localSessionUUID: localSessionUUID)
            }
        }
        .sheet(item: $mainViewState.isShowingProtectedDeepLink) { identifiableURL in
            DeepLinkPasswordView(url: identifiableURL)
        }
        .sheet(item: $mainViewState.isShowingSafariWebView) { safariContent in
            SafariWebView(url: safariContent.url)
                .ignoresSafeArea()
        }
        .customAlert(isPresented: $mainViewState.isShowingReviewAlert) {
            AskForReviewView(
                appName: Constants.appName,
                feedbackURL: STResourcesStrings.Localizable.urlUserReport,
                reviewManager: reviewManager,
                onLike: {
                    matomo.track(eventWithCategory: .appUpdate, name: "like")
                    UserDefaults.shared.appReview = .readyForReview
                    UserDefaults.shared.hasReviewedApp = true
                },
                onDislike: { userReportURL in
                    UserDefaults.shared.appReview = .feedback
                    UserDefaults.shared.hasReviewedApp = true
                    mainViewState.isShowingSafariWebView = IdentifiableURL(url: userReportURL)
                }
            )
        .discoveryPresenter(isPresented: $mainViewState.isShowingUpdateAvailable) {
            UpdateVersionView(
                image: STResourcesAsset.Images.documentStarsRocketSmall.swiftUIImage
            ) { willUpdate in
                if willUpdate {
                    openURL(UpdateLink.getStoreURL())
                    matomo.track(eventWithCategory: .appUpdate, name: "discoverNow")
                } else {
                    matomo.track(eventWithCategory: .appUpdate, name: "discoverLater")
                }
            }
        }
    }

    private func willEnterForeground() {
        Task {
            try? await injection.transferManager.deleteExpiredTransfers()
        }
    }
}

#Preview {
    MainView()
}
