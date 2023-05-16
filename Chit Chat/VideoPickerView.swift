//
//  VideoPickerView.swift
//  Chit Chat
//
//  Created by IPS-108 on 11/05/23.
//

import PhotosUI
import SwiftUI
import UIKit
import AVKit
import AVFoundation
import FirebaseStorage
import FirebaseFirestore

struct VideoPicker: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var videoURL: URL?
    @State private var isShowingVideoPicker = false
    
    private func pickVideo() {
        isShowingVideoPicker = true
    }
    
    private func handleVideoPickerResult(_ videoURL: URL) {
        self.videoURL = videoURL
    }
    // register app delegate for Firebase setup
    var body: some View {
        VStack {
            Button(action: pickVideo) {
                Text("Select Video from Gallery")
            }
            .padding()
            .sheet(isPresented: $isShowingVideoPicker) {
                
                ImagePickerDelegate(sourceType: .photoLibrary, mediaTypes: ["public.movie"], didPickVideo: handleVideoPickerResult)
            }
            
            
            if let videoURL = videoURL {
                
                VideoPlayerView(videoURL: videoURL)
                    .frame(height: 200)
                
            } else {
                Text("Tap the button to select a video")
                    .padding()
            }
            
            Button("Upload Video") {
                if let videoURL = videoURL {
                    upload(file: videoURL) { url in
                        if let downloadURL = url {
                            let firestoreRef = Firestore.firestore().collection("videos").document()
                            let data = [
                                "url": downloadURL.absoluteString,
                                "likes": 0,
                                "comments": []
                            ] as [String : Any]
                            firestoreRef.setData(data) { error in
                                if let error = error {
                                    print("Error writing video to Firestore: \(error)")
                                } else {
                                    print("Video uploaded to Firestore")
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
}

extension VideoPicker {
    func upload(file: URL, completion: @escaping ((_ url : URL?) -> ())) {
        let name = "\(UIDevice.current.identifierForVendor?.uuidString ?? "")-\(UUID().uuidString).mp4"
        do {
            let data = try Data(contentsOf: file)
            
            let storageRef =
                Storage.storage().reference().child("Videos").child(name)
            if let uploadData = data as Data? {
                let metaData = StorageMetadata()
                metaData.contentType = "video/mp4"
                storageRef.putData(uploadData, metadata: metaData
                                   , completion: { (metadata, error) in
                                    if let error = error {
                                        print("Error writing video to Firestore: \(error)")
                                        completion(nil)
                                    }
                                    else{
                                        storageRef.downloadURL { (url, error) in
                                            guard let downloadURL = url else {
                                                completion(nil)
                                                return
                                            }
                                            completion(downloadURL)
                                        }
                                        print("success")
                                    }
                                   })
            }
        } catch let error {
            print(error)
        }
    }

}

struct ImagePickerDelegate: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let mediaTypes: [String]
    let didPickVideo: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.mediaTypes = mediaTypes
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(didPickVideo: didPickVideo)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let didPickVideo: (URL) -> Void
        
        init(didPickVideo: @escaping (URL) -> Void) {
            self.didPickVideo = didPickVideo
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let videoURL = info[.mediaURL] as? URL {
                didPickVideo(videoURL)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct VideoPlayerView: View {
    var videoURL: URL
    
    var body: some View {
        VideoPlayer(player: AVPlayer(url: videoURL))
            .onAppear {
                // Auto-play the video when the view appears
                let player = AVPlayer.shared()
                player.play()
            }
            .onDisappear {
                // Pause the video when the view disappears
                let player = AVPlayer.shared()
                player.pause()
            }
    }
}

extension AVPlayer {
    static func shared() -> AVPlayer {
        struct Singleton {
            static let instance = AVPlayer()
        }
        return Singleton.instance
    }
}


struct VideoPickerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPicker()
    }
}
