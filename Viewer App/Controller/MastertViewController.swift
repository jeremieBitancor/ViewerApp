//
//  ViewController.swift
//  Viewer App
//
//  Created by jeremie bitancor on 6/2/21.
//

import UIKit

protocol DataSelectionDelegate {
    func dataSelected(_ newData: PdfPost)
}

class MasterViewController: UITableViewController, DataManagerDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var pdfList = [PdfItem]()
    var pdf = PdfItem()
    var img = ImageItem()
    var foundCharacters = ""
    
    let dataManager = DataManager()
    var returnedImgurImages = [PostData]()
    
    var dataList = [PdfPost]()
    var tempDataList = [PdfPost]()
    
    var delegate: DataSelectionDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        tableView.dataSource = self
        tableView.delegate = self
        dataManager.delegate = self
        self.clearsSelectionOnViewWillAppear = true
        
        /// Read xml from bundle
        if let path = Bundle.main.url(forResource: "contents", withExtension: "xml"){
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                /// Parse the xml
                parser.parse()
            }
        }
                
    }

    /// Delegate to get data from imgur
    func didGetData(_ pdfPost: [PdfPost]) {
        /// Add image data to pdf data
        dataList += pdfPost
        /// After adding images, add dummy data with no value
        dataList.append(PdfPost(title: "Dummy", description: "Dummy", detail: "Dummy"))
        activityIndicator.stopAnimating()
        
        tableView.reloadData()
    }
}


//MARK: - Tableview Datasource
extension MasterViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return dataList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
   
        let data = dataList[indexPath.row]
        cell.textLabel?.text = data.title
        cell.detailTextLabel?.text = data.description
        
        return cell
    }
    
}

//MARK: - Tableview Delegate
extension MasterViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedData = dataList[indexPath.row]
        
        if selectedData.title == "Dummy" {
            let alert = UIAlertController(title: "Error", message: "File not found.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            tableView.deselectRow(at: indexPath, animated: true)
            present(alert, animated: true, completion: nil)
        } else {
            delegate?.dataSelected(selectedData)
            if
                let detailViewController = delegate as? DetailViewController,
                let detailNavigationController = detailViewController.navigationController {
                splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
            }
        }
        
    }
}

//MARK: - XML Parser Delegate
extension MasterViewController: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        /// Parse the image
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
        /// Parse the pdf's
        if elementName == "filename" {
            pdf.fileName = self.foundCharacters
        } else if elementName == "description" {
            pdf.description = self.foundCharacters
        } else if elementName == "pdf-item" {

            dataList.append(PdfPost(title: pdf.fileName, description: pdf.description, detail: pdf.fileName))
            
        }
        self.foundCharacters = ""
    }
    
    /// Cleaning the strings
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.foundCharacters += data
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        /// Call fetch images after xml's images was parse
        if(img.convertedRetrieveImages && img.convertedImageCount > 0) {
            dataManager.fetchImages(withCount: img.convertedImageCount)
        } else {
            /// If retrieve images is false or image count is not greater than zero, add dummy data with no value
            dataList.append(PdfPost(title: "Dummy", description: "Dummy", detail: "Dummy"))
            activityIndicator.stopAnimating()
        }
        
    }

}

