//
//  ViewController.swift
//  PrefetchDemo
//
//  Created by Madhusudhan, Srikanth on 7/12/16.
//  Copyright © 2016 GoodSp33d. All rights reserved.
//

import UIKit

private let basePath = "https://api.500px.com"
private let photosAPI = "/v1/photos"
private let searchAPI = "/v1/photos/search"
private let consumerKey = "xHkW9aeTnoYk4k1lUYicCjbKY9VXjYOWxE3OsBt8"

class ViewController: UIViewController {
    
    var collectionView:UICollectionView?
    var photos = [Photo]()
    var imageCache:[Int:UIImage] = [:]
    var currentPage = 1
    var totalPages = 1
    var isDataLoading = false
    var searchTerm = "Camaro"
    
    let restClient = RESTClient()
    let searchField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTodaysPhotos()
        setupView()
        setupConstraints()
    }
    
    // MARK: - View Helpers
    
    private func setupView() {
        searchField.placeholder = "Search here ..."
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.returnKeyType = .search
        searchField.delegate = self
        searchField.borderStyle = .roundedRect
        searchField.autocorrectionType = .no
        view.addSubview(searchField)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: 150, height: 150)
        flowLayout.sectionInset = UIEdgeInsetsZero
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: flowLayout)
        collectionView?.dataSource = self
        collectionView?.prefetchDataSource = self
        collectionView?.delegate = self
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.backgroundColor = UIColor.white()
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView!)
    }
    
    private func setupConstraints() {
        let views = [
            "s": searchField,
            "c":collectionView!
        ]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[c]|", options: NSLayoutFormatOptions.directionLeftToRight, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[s]-|", options: NSLayoutFormatOptions.directionLeftToRight, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[s]-[c]|", options: NSLayoutFormatOptions.directionLeftToRight, metrics: nil, views: views))
    }

    // MARK: - API Requests
    
    func fetchTodaysPhotos() {
        guard !isDataLoading else {
            return
        }
        isDataLoading = true
        let urlString = basePath + searchAPI
        let parameters:[String:AnyObject] = [
            "feature":"popular",
            "sort":"created_at",
            "image_size":"3",
            "include_store":"store_download",
            "include_states":"voted",
            "consumer_key":consumerKey,
            "page":"\(currentPage)",
            "term":searchTerm
        ]
        restClient.GET(url: urlString, parameters: parameters) { (response, error) in
            if let json = response as? [String:AnyObject] {
                let photos = Photos(jsonDictionary: json)
                self.photos.append(contentsOf: photos.photos)
                self.totalPages = photos.totalPages
                self.isDataLoading = false
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                })
            }
        }
    }
    
    func downloadImage(fromURL urlString:String, completionHandler:((image:UIImage?) -> Void)) {
        let restClient = RESTClient()
        restClient.DOWNLOAD(url: urlString, parameters: nil) { (response, error) in
            if let d = response, image = UIImage(data: d) where error == nil {
                completionHandler(image: image)
            } else {
                completionHandler(image: nil)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let c = cell as? PhotoCell, i = imageCache[indexPath.row] {
            c.imageView.image = i
        } else if let c = cell as? PhotoCell {
            let imageURL = photos[indexPath.row].photoURL
            downloadImage(fromURL: imageURL, completionHandler: { (image) in
                DispatchQueue.main.async(execute: { 
                    self.imageCache[indexPath.row] = image
                    c.imageView.image = image
                })
            })
        }
        return cell
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension ViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if imageCache[indexPath.row] == nil {
                downloadImage(fromURL: photos[indexPath.row].photoURL, completionHandler: { (image) in
                    if let i = image {
                        self.imageCache[indexPath.row] = i
                    }
                })
            }
        }
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height
        let scrollViewContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y
        
        if scrollOffset + scrollViewHeight >= (scrollViewContentSizeHeight - 50) {
            print("Attempting to reload")
            currentPage += 1
            if currentPage < totalPages {
                fetchTodaysPhotos()
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let t = textField.text {
            searchTerm = t
            imageCache = [:]
            photos = []
            collectionView?.reloadData()
            textField.resignFirstResponder()
            fetchTodaysPhotos()
        }
        return false
    }
}

