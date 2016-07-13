//
//  PhotoCell.swift
//  PrefetchDemo
//
//  Created by Madhusudhan, Srikanth on 7/12/16.
//  Copyright © 2016 GoodSp33d. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    // MARK: - View Helpers
    
    private func setupView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
    }
    
    private func setupConstraints() {
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[i]|", options: NSLayoutFormatOptions.directionLeftToRight, metrics: nil, views: ["i":imageView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[i]|", options: NSLayoutFormatOptions.directionLeftToRight, metrics: nil, views: ["i":imageView]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
