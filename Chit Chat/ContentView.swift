//
//  ContentView.swift
//  Chit Chat
//
//  Created by IPS-161 on 03/05/23.
//

import SwiftUI
import AVKit
import MobileCoreServices
import FirebaseStorage
import Firebase
import FirebaseFirestore


struct Video : Identifiable {
    var id: Int
    var player : AVPlayer
    var replay : Bool
}

//struct VideView: View {
//
//    let videoRef: DocumentReference
//    @State private var player: AVPlayer?
//
//    var body: some View {
//        VStack {
//            VideoPlayer(player: player)
//                .onAppear {
//
//                    videoRef.getDocument { (document, error) in
//                        if let document = document, document.exists {
//                            print("Document Full Response : \(document)")
//                            let videoURL = document.data()?["url"] as? String
//                            print("Document videoURL Response : \(videoURL)")
//                            let videoLikes = document.data()?["likes"] as? String
//                            //let videoComments = document.data()?["comments"] as? String
//                            self.player = AVPlayer(url: URL(string: videoURL ?? "hello")!)
//                        } else {
//                            print("Document does not exist")
//                        }
//                    }
//            }
//        }
//    }
//
//}


class MyViewModel: ObservableObject {
    
    @Published var videoURL: String = ""
    let videoRef = Firestore.firestore().collection("videos").document("68H8nQPdElpJZx0gKgvD")
    var vidsUrl : String = ""

    func getData() {
        videoRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.videoURL = document.data()?["url"] as! String
                print(self.videoURL)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func shareLink() {
        getData()
        print("\(videoURL)")
        let av = UIActivityViewController(activityItems: [videoURL], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    }
}


struct PlayerView : View{
    @Binding var data : [Video]
 

    var body : some View{
        VStack(spacing: 0){
            
            ForEach(0..<self.data.count, id: \.self){ i in
                ZStack{
                    Player(player: self.data[i].player)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .offset(y: -5)
                    
                    if self.data[i].replay{
                        Button(action: {
                            
                            self.data[i].replay = false
                            self.data[i].player.seek(to: .zero)
                            self.data[i].player.play()
                            
                        }) {
                            Image(systemName: "goforward")
                                .resizable()
                                .frame(width: 55, height: 60)
                                .foregroundColor(.white)
                        }
                    }
                    SideView()
                    //SideView(videoURL: videoURL)
                }
            }
        }

        
        .onAppear(){
            print(data.count)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                //if data.count > 0 {
                    self.data[0].player.play()
                    self.data[0].player.actionAtItemEnd = .none
                    NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.data[0].player.currentItem, queue: .main) { (_) in
                        self.data[0].replay = true
                    }
                //}
            }
        }
    }
}




struct HomeView: View {
    @State var data: [Video] = []
    @State private var videoDocs: [DocumentSnapshot] = []
    private let videosRef = Firestore.firestore().collection("videos")
    

    var body: some View {
        NavigationView {
            ZStack{
                PlayerScrollView(data: $data)
                VStack{
                    VStack{
                        Spacer()
                        HStack (spacing: 40){
                            Button(action: {}) {
                                HStack(alignment: .center, spacing: 5.0) {
                                    Image(systemName: "house.fill")
                                        .resizable()
                                        .frame(width: 25.0, height: 25.0)
                                        .foregroundColor(.white)
                                }
                            }
                            Button(action: {}) {
                                HStack(alignment: .center, spacing: 5.0) {
                                    Image(systemName: "magnifyingglass")
                                        .resizable()
                                        .frame(width: 25.0, height: 25.0)
                                        .foregroundColor(.gray)
                                }
                            }
                            Section {
                                NavigationLink(
                                    destination: VideoPicker(),
                                    label: {
                                        HStack(alignment: .center, spacing: 5.0) {
                                            Image(systemName: "plus")
                                                .resizable()
                                                .frame(width: 30.0, height: 30.0)
                                                .foregroundColor(.black)
                                                .frame(width: 50, height: 50)
                                        }
                                    })
                                    .background(Color.gray)
                                    .cornerRadius(5.0)
                            }
                            
                            Button(action: {}) {
                                HStack(alignment: .center, spacing: 5.0) {
                                    Image(systemName: "message")
                                        .resizable()
                                        .frame(width: 25.0, height: 25.0)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Button(action: {}) {
                                HStack(alignment: .center, spacing: 5.0) {
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .frame(width: 25.0, height: 25.0)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                    }
                }
                .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
                .padding(.bottom,(UIApplication.shared.windows.first?.safeAreaInsets.bottom)! + 5)
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                fetchVideos()
            }
        }
    }

    private func fetchVideos() {
        
        //let mvModel = MyViewModel()
        
        videosRef.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching videos: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            let videos = snapshot.documents.compactMap { document -> Video? in
                guard let urlStr = document.data()["url"] as? String,
                      let url = URL(string: urlStr)//,mvModel.vidsUrl == urlStr
                else {
                    return nil
                }
                //print("Document Full Response : \(document)")
                //print("videos Full Response : \(url)")
               
                return Video(id: Int.random(in: 0..<1000), player: AVPlayer(url: url), replay: false)
            }
            self.data = videos
            self.videoDocs = snapshot.documents
            //print(videos)
        }
    }
}




struct Player : UIViewControllerRepresentable{
    
    var player : AVPlayer
    
    func makeUIViewController(context: Context) -> some AVPlayerViewController {
        
        let view = AVPlayerViewController()
        view.player = player
        view.showsPlaybackControls = false
        view.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
}

struct PlayerScrollView : UIViewRepresentable{
    
    func makeCoordinator() -> Coordinator {
        return PlayerScrollView.Coordinator(parent1: self)
    }
    
    @Binding var data : [Video]
    
    func makeUIView(context: Context) -> UIScrollView {
        let view = UIScrollView()
        
        let childView = UIHostingController(rootView: PlayerView(data: self.$data))
        
        childView.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * CGFloat(data.count))
        
        view.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * CGFloat(data.count))
        
        view.addSubview(childView.view)
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        
        view.contentInsetAdjustmentBehavior = .never
        view.isPagingEnabled = true
        view.delegate = context.coordinator
        
        return view
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        uiView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * CGFloat(data.count))
        
        for i in 0..<uiView.subviews.count{
            uiView.subviews[i].frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * CGFloat(data.count))
        }
    }
    
    class Coordinator : NSObject, UIScrollViewDelegate{
        
        var parent : PlayerScrollView
        var index = 0
        
        init(parent1 : PlayerScrollView) {
            parent = parent1
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let currentIndex = Int(scrollView.contentOffset.y / UIScreen.main.bounds.height)
            
            if index != currentIndex{
                index = currentIndex
                
                for i in 0..<parent.data.count{
                    parent.data[i].player.seek(to: .zero)
                    parent.data[i].player.pause()
                }
                
                
                self.parent.data[index].replay = false
                parent.data[index].player.play()
                parent.data[index].player.actionAtItemEnd = .none
                
                NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: parent.data[index].player.currentItem, queue: .main) { (_) in
                    
                    self.parent.data[self.index].replay = true
                }
            }
        }
    }
}



struct SideView : View {
    
    @State var showingSheet = false
    @State var showingSheetVideo = false
    @State var countVideoLikes = 999
    @State var countComments = 30300
    @State var isButtonClicked = false
    @StateObject var viewModel = MyViewModel()
    
    var body : some View{
        VStack{
            HStack{
                Spacer()
                VStack(spacing: 30){
                    VStack(spacing: 5) {
                        Button(action: {
                            
                            if self.isButtonClicked{
                                self.countVideoLikes -= 1
                            }
                            else{
                                self.countVideoLikes += 1
                            }
                            
                            self.isButtonClicked.toggle()
                        }) {
                            
                            Image(systemName: self.isButtonClicked ? "heart.fill" : "heart")
                                .resizable()
                                .frame(width: 30.0, height: 30.0)
                        }
                        .foregroundColor(self.isButtonClicked ? Color.pink : Color.white)
                        Text("\(countVideoLikes)")
                    }
                    .foregroundColor(.white)
                    VStack(spacing:5){
                        Button(action: {showingSheet.toggle()})
                        {
                            Image(systemName: "message")
                                .resizable()
                                .frame(width: 30.0, height: 30.0)
                        }
                        .sheet(isPresented: $showingSheet)
                        {
                            SheetView()
                        }
                        Text("\(countComments)")
                    }
                    .foregroundColor(.white)
                    VStack(spacing:5){
                        Button(action: viewModel.shareLink) {
                            
                            Image(systemName: "arrowshape.turn.up.right.fill")
                                .resizable()
                                .frame(width: 30.0, height: 30.0)
                            
                        }
                        Text("Share")
                    }
                    .foregroundColor(.white)
                    
                }
                .padding(.top,350)
                
            }
            .padding()
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

