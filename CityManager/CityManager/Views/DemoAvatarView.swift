//
//  DemoAvatarView.swift
//  SwipeFresh
//
//  Created by Aleksandra Topalova on 29.03.24.
//

import SwiftUI
import AVFoundation
import AVKit
import Foundation

struct DemoAvatarView: UIViewRepresentable {
    @Binding var talking: Bool

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        // Initialize the player with the first video selection
        setupVideoPlayer(with: talking, in: view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the player with the new video selection
        setupVideoPlayer(with: talking, in: uiView)
    }
    
    private func setupVideoPlayer(with talking: Bool, in view: UIView) {
        // Determine the video file based on the selection
        var videoName = talking ? "talking_avatar" : "not_talking_avatar"

        guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else {
            print("Couldn't find video")
            return
        }
        
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        if let playerLayer = view.layer.sublayers?.first(where: { $0 is AVPlayerLayer }) as? AVPlayerLayer {
            playerLayer.player = player
        } else {
            let playerLayer = AVPlayerLayer(player: player)
            view.layer.addSublayer(playerLayer)
            playerLayer.frame = view.bounds
            playerLayer.videoGravity = .resizeAspect
        }
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero)
            player.play()
        }
        
        player.play()
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        // Stop the player and remove observers when the view is dismantled
        if let playerLayer = uiView.layer.sublayers?.first(where: { $0 is AVPlayerLayer }) as? AVPlayerLayer,
           let player = playerLayer.player {
            player.pause()
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        }
    }
}
