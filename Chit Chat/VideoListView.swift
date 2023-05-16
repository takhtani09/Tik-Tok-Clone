//
//  VideoListView.swift
//  Chit Chat
//
//  Created by IPS-108 on 12/05/23.
//

import SwiftUI
import Firebase
import AVKit
import FirebaseFirestore

struct VidView: View {
    let videoRef: DocumentReference
    @State private var player: AVPlayer?
    
    var body: some View {
        VStack {
            VideoPlayer(player: player)
                .onAppear {
                    videoRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let videoURL = document.data()?["url"] as? String
                            print("\(videoURL)")
                            self.player = AVPlayer(url: URL(string: videoURL ?? "hello")!)
                        } else {
                            print("Document does not exist")
                        }
                    }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct VideoListView: View {
    @State private var videoDocs: [DocumentSnapshot] = []
    private let videosRef = Firestore.firestore().collection("videos")
    @State private var videoURLs: [String] = [] 
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(videoDocs, id: \.documentID) { document in
                        VidView(videoRef: document.reference)
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .frame(width: 400, height: 2500, alignment: .center)
                
            }
            .navigationTitle("Videos")
        }
        .onAppear {
            videosRef.addSnapshotListener { snapshot, error in
                if let snapshot = snapshot {
                    videoDocs = snapshot.documents
                    videoURLs = snapshot.documents.compactMap { $0.data()?["url"] as? String } // Store the video URLs in the array
                    print(videoURLs)
                }
            }
        }
    }
}

