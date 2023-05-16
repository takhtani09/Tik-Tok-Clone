//
//  CommentsView.swift
//  Chit Chat
//
//  Created by IPS-161 on 04/05/23.
//

import SwiftUI
//@Environment(\.presentationMode) var dismiss
struct Comment: Identifiable {
    let id = UUID()
    let text: String
    var likes: Int
}
struct SheetView: View {
    //@Environment(\.presentationMode) var dismiss
    @State var comment = ""
    @State var comments = [(text: String, liked: Bool, count: Int)]()
    
    var body: some View {
        VStack {
            HStack {
                TextField("Comment here", text: $comment)
                    .padding(.horizontal)
                Button(action: {
                    self.comments.append((text: comment, liked: false, count: 10))
                    comment = ""
                }) {
                    Image(systemName: "paperplane")
                        .padding(.horizontal)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1).foregroundColor(Color.gray))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(0..<comments.count, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(comments[index].text)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            HStack(spacing:20){
                                HStack(spacing:0){
                                    Button(action: {
                                        comments[index].liked.toggle()
                                        if comments[index].liked {
                                            comments[index].count += 1
                                        } else {
                                            comments[index].count -= 1
                                        }
                                    }) {
                                        Image(systemName: comments[index].liked ? "heart.fill" : "heart")
                                            .foregroundColor(comments[index].liked ? .pink : .gray)
                                    }
                                    Image(uiImage: UIImage(data: Data()) ?? UIImage())
                                    Text("\(comments[index].count)")
                                    
                                }
                                Button(action: {}) {
                                    Text("Reply")
                                }

                            }
                            .foregroundColor(.gray)
                        }
//                        .padding(.vertical, 5)
//                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1).foregroundColor(Color.gray))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
        }
        .foregroundColor(.black)
        .padding()
    }
}

struct CommentsView: View {
    var body: some View {
        SheetView()
    }
}

struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        CommentsView()
    }
}
