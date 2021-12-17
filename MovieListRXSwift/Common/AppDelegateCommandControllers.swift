//
//  AppDelegateCommandControllers.swift
//  360MedicsTestProject
//
//  Created by Guillaume Bourachot on 13/12/2021.
//
import UIKit
import Foundation

protocol Command {
    func execute()
}

final class StartupCommandsBuilder {
    private var window: UIWindow!
    private var application: UIApplication!
    private var launchOptions: [UIApplication.LaunchOptionsKey: Any]?

    func setKeyWindow(_ window: UIWindow) -> StartupCommandsBuilder {
        self.window = window
        return self
    }

    func setLaunchOptions(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> StartupCommandsBuilder {
        self.launchOptions = launchOptions
        return self
    }

    func setApplication(_ application: UIApplication) -> StartupCommandsBuilder {
        self.application = application
        return self
    }

    func build() -> [Command] {
        return [
            InitialViewControllerCommand(keyWindow: window)
        ]
    }
}

struct InitialViewControllerCommand: Command {
    let keyWindow: UIWindow

    func execute() {
        let movieListViewController = MovieListViewController()
        let navigationController = UINavigationController(rootViewController: movieListViewController)
        navigationController.navigationBar.setUpNavigationBarColors(displayMode: .mainColor)
        let digiSchoolLogo = UIImage.init(named: "LogoMovieHunt")
        let logoImageView = UIImageView(image: digiSchoolLogo)
        navigationController.navigationBar.topItem?.titleView = logoImageView
        keyWindow.rootViewController = navigationController
    }
}
