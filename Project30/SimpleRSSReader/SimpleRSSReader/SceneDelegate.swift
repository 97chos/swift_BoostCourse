//
//  SceneDelegate.swift
//  SimpleRSSReader
//
//  Created by sangho Cho on 2021/05/10.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?


  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    guard let scene = (scene as? UIWindowScene) else { return }

    let navigationController = UINavigationController(rootViewController: ViewController(viewModel: ViewModel()))
    self.window = UIWindow(frame: UIScreen.main.bounds)
    self.window?.rootViewController = navigationController
    self.window?.windowScene = scene
    self.window?.makeKeyAndVisible()

  }
}

