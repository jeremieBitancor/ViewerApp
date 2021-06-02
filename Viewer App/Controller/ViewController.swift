//
//  ViewController.swift
//  Viewer App
//
//  Created by jeremie bitancor on 6/2/21.
//

import UIKit

class ViewController: UIViewController, DataManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
//    var viewerItems = ViewerItems()
    var pdfList = [PdfItem]()
    var pdf = PdfItem()
    var img = ImageItem()
    var foundCharacters = ""
    
    let dataManager = DataManager()
    var returnedImgurImages = [PostData]()
    
    var dataList = [PdfPost]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        dataManager.delegate = self
        
        if let path = Bundle.main.url(forResource: "contents", withExtension: "xml"){
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                parser.parse()
            }
        }
    }

    func didGetData(_ pdfPost: [PdfPost]) {
        dataList += pdfPost
        tableView.reloadData()
    }
}

//MARK: - Tableview Datasource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return pdfs.count
       
        return dataList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        if indexPath.row + 1 == dataList.count + 1 {
            cell.textLabel?.text = "Dummy"
        } else {
            let data = dataList[indexPath.row]
            cell.textLabel?.text = data.title
            cell.detailTextLabel?.text = data.description
        }
        return cell
    }
    
}

//MARK: - Tableview Delegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        if indexPath.row + 1 == dataList.count + 1 {
            let alert = UIAlertController(title: "Error", message: "File not found.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - XML Parser Delegate
extension ViewController: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            
        if elementName == "image-list" {
            let tempImage = ImageItem()
            if let retrieveImage = attributeDict["retrieve_images"] {
                tempImage.retrieve_images = retrieveImage
            }
            if let imageCount = attributeDict["image_count"] {
                tempImage.image_count = imageCount
            }
            img = tempImage
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "filename" {
            pdf.fileName = self.foundCharacters
        } else if elementName == "description" {
            pdf.description = self.foundCharacters
        } else if elementName == "pdf-item" {

            dataList.append(PdfPost(title: pdf.fileName, description: pdf.description, detail: pdf.fileName))
            
        }
        self.foundCharacters = ""
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.foundCharacters += data
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        
        if(img.convertedRetrieveImages) {
            dataManager.fetchImages(withCount: img.convertedImageCount)
        }
    }

}

