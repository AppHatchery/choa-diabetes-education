//
//  SceneDelegate.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/4/22.
//

import UIKit
import AVFoundation
import Pendo

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    /// Temporarily off so every launch goes straight to the main app; set back to true to bring onboarding back
    private let isAppOnboardingEnabled = false


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }

        // The scene launches from the AppOnboarding storyboard; skip straight to
        // the main app once the user has already been through onboarding.
        if !isAppOnboardingEnabled || AppOnboardingManager.shared.hasCompletedOnboarding {
            window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()

            // A tapped notification should open its screen straight away, so it skips the intro
            if RemoteConfigManager.shared.isHalloweenThemeEnabled && connectionOptions.notificationResponse == nil {
                playHalloweenLaunchVideo()
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(applyThemeAppIcon), name: .halloweenThemeDidChange, object: nil)
    }

    /// Matches the home screen icon to the theme: the Halloween icon while it's on, the regular one otherwise.
    /// iOS only allows this while the app is active, and always shows its own "You have changed the icon" alert,
    /// so it waits until the intro video has finished rather than interrupting it.
    @objc private func applyThemeAppIcon() {
        let application = UIApplication.shared
        guard application.supportsAlternateIcons,
              application.applicationState == .active,
              window?.subviews.contains(where: { $0 is LaunchVideoView }) != true else { return }

        let iconName: String? = RemoteConfigManager.shared.isHalloweenThemeEnabled ? "HalloweenAppIcon" : nil
        guard application.alternateIconName != iconName else { return }

        application.setAlternateIconName(iconName) { error in
            if let error {
                print("App icon change failed: \(error.localizedDescription)")
            }
        }
    }

    /// Plays the Halloween intro over the home screen, which fades in once the video ends.
    private func playHalloweenLaunchVideo() {
        guard let window else { return }

        // Show the window first so the root view is installed underneath the video, not on top of it
        window.makeKeyAndVisible()

        LaunchVideoView.playHalloweenLaunch(in: window) { [weak self] in
            self?.applyThemeAppIcon()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.

        // Catches a theme change that arrived while the app was in the background
        applyThemeAppIcon()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
      if let url = URLContexts.first?.url, url.scheme?.range(of: "pendo") !=
    nil {
        PendoManager.shared().initWith(url)
      }
      // your code here…
    }


}

/// Full-screen video laid over the window that fades away to reveal the app when it finishes.
/// It plays through to the end; touches stop at the video rather than reaching the app underneath.
final class LaunchVideoView: UIView {

    /// Lays the Halloween intro over the whole window and plays it, unless one is already playing.
    /// At launch it covers the app straight away; replaying it from the app fades it in instead.
    static func playHalloweenLaunch(in window: UIWindow, fadesIn: Bool = false, onFinish: (() -> Void)? = nil) {
        guard !window.subviews.contains(where: { $0 is LaunchVideoView }),
              let url = Bundle.main.url(forResource: "halloween_launch", withExtension: "mp4") else { return }

        let videoView = LaunchVideoView(url: url)
        videoView.onFinish = onFinish
        videoView.frame = window.bounds
        videoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(videoView)
        videoView.play()

        if fadesIn {
            videoView.alpha = 0
            UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut) {
                videoView.alpha = 1
            }
        }
    }

    override class var layerClass: AnyClass { AVPlayerLayer.self }

    private let player: AVPlayer
    private var endObserver: NSObjectProtocol?
    private var statusObservation: NSKeyValueObservation?
    private var isDismissing = false
    /// Called once the video has faded away and been removed
    private var onFinish: (() -> Void)?

    init(url: URL) {
        player = AVPlayer(url: url)
        super.init(frame: .zero)

        backgroundColor = .black
        let playerLayer = layer as! AVPlayerLayer
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func play() {
        // Mix with, rather than stop, whatever the user is already listening to
        try? AVAudioSession.sharedInstance().setCategory(.ambient)

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.fadeOut()
        }

        // A video that can't play shouldn't leave the user on a black screen
        statusObservation = player.currentItem?.observe(\.status) { [weak self] item, _ in
            guard item.status == .failed else { return }
            DispatchQueue.main.async { self?.fadeOut() }
        }

        player.play()
    }

    private func fadeOut() {
        guard !isDismissing else { return }
        isDismissing = true

        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
        statusObservation = nil

        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut) {
            self.alpha = 0
        } completion: { _ in
            self.player.pause()
            self.removeFromSuperview()
            self.onFinish?()
        }
    }
}

