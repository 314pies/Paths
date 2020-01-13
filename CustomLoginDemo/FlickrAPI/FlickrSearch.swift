//
//  FlickrCollectionViewController.swift
//  PhotoDemo
//
//  Created by SHIH-YING PAN on 2019/1/11.
//  Copyright © 2019 SHIH-YING PAN. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"


class FlickrSearch{

    static var photos = [Photo]()
    static var filePathes : Array<String> = Array<String>()
    
    //24.826990
    //121.013000
    static func fetchData(lat: String, lon: String) {
        print("Fetching Flicker data from location: ",lat," and ",lon)
        if let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=535a87a2f2c770de1777c7a7931a724f&per_page=20&format=json&nojsoncallback=1&lat="+lat+"&lon="+lon) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, let searchData = try? JSONDecoder().decode(SearchData.self, from: data) {
                    photos = searchData.photos.photo
                    
                    for p in photos{
                        print(p.imageUrl)
                        
                        NetworkUtility.downloadImage(url: p.imageUrl) { (image) in
                            do {
                                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                let fileName = UUID().uuidString
                                let fileURL = documentsURL.appendingPathComponent("\(fileName).png")
                                let filePath = documentsURL.appendingPathComponent("\(fileName).png").path
                                
                                filePathes.append(filePath)
                                if let pngImageData = image!.pngData() {
                                    try pngImageData.write(to: fileURL, options: .atomic)
                                    
                                    print("Flickr image saved! file Path: ", filePath)
                                }
                            } catch { }
                        }
                    }
                }
                
            }
        
            task.resume()
        }
        
    }
}
