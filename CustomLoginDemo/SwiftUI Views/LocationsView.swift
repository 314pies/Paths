//
//  LocationsView.swift
//  CustomLoginDemo
//
//  Created by Ian Chen on 2020/1/13.
//  Copyright © 2020 Christopher Ching. All rights reserved.
//

import SwiftUI
import CoreData

struct LocationsView: View {
    
    let names = ["Raju", "Ghanshyam", "Baburao Ganpatrao Apte", "Anuradha", "Kabira", "Chaman Jhinga", "Devi Prasad", "Khadak Singh"]
    
    @State private var searchTerm : String = ""
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    init() {
        
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
//        do {
//
//            let results =
//                try moc.fetch(request) as! [Location]
//
//            for result in results {
//                print("Core data readed. Title: ",result.title," content: ", result.content)
//            }
//
//        } catch {
//            fatalError("\(error)")
//        }
//
//
//        //
//
//       let fetchRequest = NSFetchRequest<Location>(entityName: "Location")
//
//
//
//       do {
//           let data = try moc.fetch(fetchRequest)
//       } catch let error as NSError {
//           print ("Could not fetch. \(error), \(error.userInfo)")
//       }
    }
    
    func GetListWithSearchTerm(searchTerm:String)-> Array<String>{
        
       let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
       var names:Array<String> = Array()
        if(!(searchTerm ?? "").isEmpty){
            request.predicate = NSPredicate(format: "title contains %@", searchTerm)
        }
        
       
        do {
           let results = try moc.fetch(request) as! [Location]

           for result in results {
            if(!(result.title ?? "").isEmpty)
            {
                names.append(result.title!)
            }
            print("Core data Founded. Title: ",result.title)
           }
           
       } catch {
           fatalError("\(error)")
       }
        
        return names
    }
    
    var body: some View {
        NavigationView{
            List {
                SearchBar(text: $searchTerm)
                ForEach(self.GetListWithSearchTerm(searchTerm: searchTerm), id: \.self) { name in
                    Text(name)
                }
            }
            .navigationBarTitle(Text("My Locations"))
        }
    }
}

struct LocationsView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsView()
    }
}

struct SearchBar : UIViewRepresentable {
    
    @Binding var text : String
    
    class Cordinator : NSObject, UISearchBarDelegate {
        
        @Binding var text : String
        
        init(text : Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }
    
    func makeCoordinator() -> SearchBar.Cordinator {
        return Cordinator(text: $text)
    }
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}
