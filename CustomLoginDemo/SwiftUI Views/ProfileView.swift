//
//  ProfileView.swift
//  CustomLoginDemo
//
//  Created by Ian Chen on 2020/1/9.
//  Copyright © 2020 Christopher Ching. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    @State private var show = false
    var body: some View {
        
        return Group {
            if show {
                HomeView()
            }
            else {
               Button("play") {
                    self.show = true
                }
//                .sheet(isPresented: $show) {
//                    StoryView()
//                }
            }
        }
//       .sheet(item: true, content:HomeView())
    }
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView()
//    }
//}

struct HomeView : UIViewControllerRepresentable{
    func makeUIViewController(context: UIViewControllerRepresentableContext<HomeView>) -> HomeViewController {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController)
        return controller as! HomeViewController
    }

    func updateUIViewController(_ uiViewController: HomeViewController, context: UIViewControllerRepresentableContext<HomeView>) {
        
    }

    typealias UIViewControllerType = HomeViewController
}

//struct StoryView :UIViewControllerRepresentable{
//    func makeUIViewController(context: UIViewControllerRepresentableContext<StoryView>) -> StoryWritterViewController {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//       let controller = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.storyWritterViewController)
//        return controlle
//    }
//
//    func updateUIViewController(_ uiViewController: StoryWritterViewController, context: UIViewControllerRepresentableContext<StoryView>) {
//
//    }
//
//    typealias UIViewControllerType = StoryWritterViewController
//
//}
