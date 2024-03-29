//
//  AvatarView.swift
//  SwipeFresh
//
//  Created by Aleksandra Topalova on 29.03.24.
//

import SwiftUI
import AVKit

import SwiftUI
import AVKit

struct AvatarView: View {
    @State var player = AVPlayer()
    @State private var videoURL: URL?
    @State private var isGenerating = true
    @State private var errorMessage: String?
    var avatarUrl = "https://create-images-results.d-id.com/DefaultPresenters/Noelle_f/image.jpeg"
    var prompt: String = "Hello there! What is your question?"
    
    var body: some View {
        VStack {
            if videoURL == nil {
                Text("Generating video...")
            } else if let videoURL = videoURL {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .onAppear {
                        player = AVPlayer(url: videoURL)
                        player.play()
                    }
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
        .onAppear {
            generateVideo()
        }
    }
    
    func generateVideo() {
        isGenerating = true
        errorMessage = nil
        AvatarService.generateVideo(prompt: prompt, avatarURL: avatarUrl) { videoUrlString in
            DispatchQueue.main.async {
                self.isGenerating = false
                if let videoUrlString = videoUrlString, let videoURL = URL(string: videoUrlString) {
                    self.videoURL = videoURL
                } else {
                    self.errorMessage = "Failed to generate video. Please try again."
                }
            }
        }
    }
}

