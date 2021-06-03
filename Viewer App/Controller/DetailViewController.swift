//
//  DetailViewController.swift
//  Viewer App
//
//  Created by jeremie bitancor on 6/2/21.
//

import UIKit
import PDFKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let imageView = UIImageView()
    let pdfView = PDFView()
    let activityIndicator = UIActivityIndicatorView()
    
    var data: PdfPost? {
        
        didSet {
            activityIndicator.startAnimating()
            refreshUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        /// Settings for zooming capabilities
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.backgroundColor = .white
        scrollView.addSubview(activityIndicator)
        
        activityIndicator.hidesWhenStopped = true
        
    }
    func refreshUI() {
        loadViewIfNeeded()
        /// Set the image to none, to indicate a new one is coming or is being fetched
        imageView.image = .none
        
        if let safeData = data {
            
            /// Check if the data is an image or pdf
            if safeData.detail.contains("pdf") {
                /// Remove image view from root view so they wont overlap
                imageView.removeFromSuperview()
                /// Trim the string to get the filename
                let filename = safeData.detail.components(separatedBy: ".")[0]
                
                /// Set view to full screen
                pdfView.frame = view.bounds
                pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                view.addSubview(pdfView)
                
                pdfView.autoScales = true
                /// Read the pdf file
                let fileURL = Bundle.main.url(forResource: filename, withExtension: "pdf")
                pdfView.document = PDFDocument(url: fileURL!)
                
            } else {
                /// Remove pdf view from the root view, so they wont overlap
                pdfView.removeFromSuperview()
                
                ///Initialize image view
                imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.contentMode = .scaleAspectFill
                view.addSubview(imageView)
                
                /// Setting image view constraint
                NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
                NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true
                NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200).isActive = true
                NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300).isActive = true
                
                /// Setting activity indicator constraint
                activityIndicator.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
                NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true
                let imageUrlString = safeData.detail
                guard let imageUrl = URL(string: imageUrlString) else {
                    return
                }
               
                /// Start activity indicator
                activityIndicator.startAnimating()
                /// Fetch and load image
                imageView.loadImage(withUrl: imageUrl) {
                    /// Stops the activity indicator
                    self.activityIndicator.stopAnimating()
                }
            }
            
        }
    }
    
}
//MARK: - Data Selection Delegate
extension DetailViewController: DataSelectionDelegate {
  func dataSelected(_ newData: PdfPost) {
    data = newData
  }
}

//MARK: - UIScrollView Delegate
extension DetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

//MARK: - UIImageView Function
/// A custom function for fetching the and setting the image to UIImageView
extension UIImageView {
    func loadImage(withUrl url: URL, finished: @escaping () -> Void ) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                        /// Completion handler to stop the activity indicator
                        finished()
                    }
                }
            }
            
        }
    }
}
