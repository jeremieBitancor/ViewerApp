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
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.backgroundColor = .white
        
        scrollView.addSubview(activityIndicator)
        
        activityIndicator.hidesWhenStopped = true
//        if let safeData = data {
//            safeData.description
//        }
        
//        let pdfView = PDFView(frame: self.view.bounds)
//
//        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        self.view.addSubview(pdfView)
//
//        pdfView.autoScales = true
//
//        let fileURL = Bundle.main.url(forResource: "relativity", withExtension: "pdf")
//        pdfView.document = PDFDocument(url: fileURL!)

      
        imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)

        NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200).isActive = true
        NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300).isActive = true

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true
        
        
    }
    func refreshUI() {
        loadViewIfNeeded()
//        label.text = data?.detail
        imageView.image = .none
        
        if let safeData = data {
            
            let imageUrlString = safeData.detail
            print(imageUrlString)
            guard let imageUrl = URL(string: imageUrlString) else {
                return
            }
           
            activityIndicator.startAnimating()

            imageView.loadImage(withUrl: imageUrl) {
                self.activityIndicator.stopAnimating()
            }
           
        }
    }
    
}

extension DetailViewController: DataSelectionDelegate {
  func dataSelected(_ newData: PdfPost) {
    
    data = newData
  }
}

extension DetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return image
        return imageView
    }
}

extension UIImageView {
    func loadImage(withUrl url: URL, finished: @escaping () -> Void ) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                        finished()
                    }
                }
            }
            
        }
    }
}
