//
//  ViewController.swift
//  Viewer App
//
//  Created by jeremie bitancor on 6/2/21.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewerItems = ViewerItems()
    var pdfList = [PdfItem]()
    var pdf = PdfItem()
    var img = ImageItem()
    var foundCharacters = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        if let path = Bundle.main.url(forResource: "contents", withExtension: "xml"){
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                parser.parse()
            }
        }
    }
}

//MARK: - Tableview Datasource
extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return pdfs.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
//        let pdf = pdfs[indexPath.row]
//        cell.textLabel?.text = pdf.filename
//        cell.detailTextLabel?.text = pdf.description
        
        return cell
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
            self.img = tempImage
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "filename" {
            self.pdf.fileName = self.foundCharacters
        } else if elementName == "description" {
            self.pdf.description = self.foundCharacters
        } else if elementName == "pdf-item" {
            let tempPdf = PdfItem()
            tempPdf.description = self.pdf.description
            tempPdf.fileName = self.pdf.fileName
            self.viewerItems.pdfItem.append(tempPdf)
            
        } else if elementName == "viewer" {
            self.viewerItems.imageItem = self.img
        }
        self.foundCharacters = ""
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.foundCharacters += data
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        
        for item in viewerItems.pdfItem {
            print(item.fileName)
            print(item.description)
        }
        print(viewerItems.imageItem.convertedImageCount)
        print(viewerItems.imageItem.convertedRetrieveImages)
    }

}
