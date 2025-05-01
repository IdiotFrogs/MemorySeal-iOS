import UIKit

import AppFeature

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene

        let navigationController = UINavigationController()
        window?.rootViewController = navigationController

        let appCoordinator: AppCoordinator = AppCoordinator(with: navigationController)
        appCoordinator.moveToLoginCoordinator()
        
        window?.makeKeyAndVisible()
    }
}
