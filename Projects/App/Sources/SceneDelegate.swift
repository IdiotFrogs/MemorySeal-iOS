import UIKit
import UserNotifications

import AppFeature
import BaseDomain

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene

        UNUserNotificationCenter.current().delegate = self

        let navigationController = UINavigationController()
        window?.rootViewController = navigationController

        let coordinator = AppCoordinator(with: navigationController)
        appCoordinator = coordinator
        coordinator.start(destination: landingDestination(from: connectionOptions))

        window?.makeKeyAndVisible()
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let destination = landingDestination(from: userActivity) else { return }
        appCoordinator?.handle(destination: destination)
    }

    // MARK: - Landing

    private func landingDestination(from connectionOptions: UIScene.ConnectionOptions) -> LandingDestination? {
        if let response = connectionOptions.notificationResponse,
           let destination = LandingLinkParser.parse(userInfo: response.notification.request.content.userInfo) {
            return destination
        }

        return connectionOptions.userActivities
            .compactMap { landingDestination(from: $0) }
            .first
    }

    private func landingDestination(from userActivity: NSUserActivity) -> LandingDestination? {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL
        else {
            return nil
        }

        return LandingLinkParser.parse(url: url)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension SceneDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .badge, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if let destination = LandingLinkParser.parse(userInfo: response.notification.request.content.userInfo) {
            appCoordinator?.handle(destination: destination)
        }
        completionHandler()
    }
}
