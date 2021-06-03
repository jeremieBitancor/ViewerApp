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
    
//    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    //    var viewerItems = ViewerItems()
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
        
        if let path = Bundle.main.url(forResource: "contents", withExtension: "xml"){
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                parser.parse()
            }
        }
        
        
        
//        let selectedData = dataList[0]
//        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
//        delegate?.dataSelected(selectedData)
                
    }

    func didGetData(_ pdfPost: [PdfPost]) {
        
        dataList = tempDataList
        dataList += pdfPost
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
       
        
//        if indexPath.row == dataList.count  {
//            let alert = UIAlertController(title: "Error", message: "File not found.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
//            tableView.deselectRow(at: indexPath, animated: true)
//            present(alert, animated: true, completion: nil)
//        } else {
        
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
        
         
//        }
        
//        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - XML Parser Delegate
extension MasterViewController: XMLParserDelegate {
    
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

            tempDataList.append(PdfPost(title: pdf.fileName, description: pdf.description, detail: pdf.fileName))
            
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

