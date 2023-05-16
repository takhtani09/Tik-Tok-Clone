//
//  ShareVideo.swift
//  Chit Chat
//
//  Created by IPS-108 on 08/05/23.
//

import SwiftUI
import PhotosUI
import FirebaseStorage

class ShareVideo: NSObject, ObservableObject {

    @Published var videoURL: URL?

    func selectVideo() {
        // Request authorization for photo library
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                print("Access granted.")
            case .denied, .restricted:
                print("Access denied.")
            case .notDetermined:
                print("Authorization not determined.")
            @unknown default:
                fatalError("New authorization status is available.")
            }
        }

        var configuration = PHPickerConfiguration()
        configuration.filter = .videos
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true)
    }


    func uploadVideo() {
        guard let videoURL = videoURL else {
            return
        }
        print(videoURL)
//        let storageRef = Storage.storage().reference(withPath: "/videos/\(UUID().uuidString).mp4")
//
//
//        storageRef.putFile(from: videoURL) { result, error in
//            print(result)
//            if error != nil {
//                print("video uploaded")
//            }else {
//                print("video not uploaded")
//            }
//        }

        upload(file: videoURL) { result in
            print(result)
        }

    }
    func upload(file: URL, completion: @escaping ((_ url : URL?) -> ())) {
        let name = "\(Int(Date().timeIntervalSince1970)).mp4"
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
        }catch let error {
            print(error)
        }

    }
}

extension ShareVideo: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)
        guard let result = results.first else {
            return
        }
        result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
            if let error = error {
                print("Error loading video: \(error.localizedDescription)")
            } else if let url = url {
                DispatchQueue.main.async {
                    self.videoURL = url
                }
            }
        }

    }
}

struct ShareVideoView: View {
    @StateObject private var shareVideo = ShareVideo()

    var body: some View {
        VStack{
            Button(action: {
                shareVideo.selectVideo()
            }){
                Text("Select Video")
            }

            Button("Upload Video") {
                shareVideo.uploadVideo()
            }
        }
    }
}

struct ShareVideoView_Previews: PreviewProvider {
    static var previews: some View {
        ShareVideoView()
    }
}
