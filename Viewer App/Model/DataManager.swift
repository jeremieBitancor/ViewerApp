//
//  ImagesDataManager.swift
//  Viewer App
//
//  Created by jeremie bitancor on 6/2/21.
//

import Foundation

protocol DataManagerDelegate {
    func didGetData(_ pdfPost: [PdfPost])
}

class DataManager {
    
    var pdfList = [PdfItem]()
    var pdf = PdfItem()
    var img = ImageItem()
    var foundCharacters = ""
    
    var delegate: DataManagerDelegate?
    
    func fetchImages(withCount num: Int) {
        
        let token = "57f39696dad5cc77cfbb51f2859f0675ede72f06"

        if let url = URL(string: "https://api.imgur.com/3/gallery/search?q=dogs&q_type=png") {
            var request = URLRequest(url: url)
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request) {( data, response, error) in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            // Decode api to Model
                            let results = try decoder.decode(PostDataList.self, from: safeData)
//                            print(results.data[10])
//                            var list = [PostData]()
                            var data: PostData
                            var dataList = [PdfPost]()
                           
                            for x in 0...num - 1 {
//                                list.append(results.data[x])
                                data = results.data[x]
                                let link = data.images?[0].link ?? data.link
                                dataList.append(PdfPost(title: data.id, description: link, detail: link))
                            }
//                            print(dataList)
                            
                            DispatchQueue.main.async {
                                // Set data using delegation
                                self.delegate?.didGetData(dataList)
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            task.resume()
        }
    }
}


