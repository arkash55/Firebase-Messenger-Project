//
//  PhotoMessageViewController.swift
//  newMessageApp
//
//  Created by Arkash Vijayakumar on 18/06/2021.
//

import UIKit

class PhotoMessageViewController: UIViewController {
    
    let photoUrl: URL
    
    private let photoImageView: UIImageView = {
        let photoImageView = UIImageView()
        photoImageView.backgroundColor = .systemBackground
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.layer.masksToBounds = true
        return photoImageView
    }()

    init(photoUrl: URL) {
        self.photoUrl = photoUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(photoImageView)
        loadImage()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        photoImageView.frame = view.bounds
    }
    
    private func loadImage() {
        DispatchQueue.main.async {
            self.photoImageView.sd_setImage(with: self.photoUrl, completed: nil)
        }
    }


}
