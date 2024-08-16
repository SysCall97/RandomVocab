//
//  ViewController+UI.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 16/8/24.
//

import UIKit

extension ViewController {
    internal func initView() {
        self.addBG()
        self.addWordLabel()
    }
    
    private func addBG() {
        guard let image = UIImage(named: "bg.jpg") else {
            fatalError("Background image not found")
        }
        
        let imageView: UIImageView = UIImageView(frame: self.view.frame)
        imageView.image = image
        imageView.center = self.view.center
        imageView.contentMode = .scaleAspectFill
        
        self.view.addSubview(imageView)
    }
    
    private func addWordLabel() {
        self.label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20))
        self.label.text = "Hello everyone"
        self.label.numberOfLines = 1
        self.label.font = UIFont.systemFont(ofSize: 40, weight: UIFont.Weight(510.0))
        self.label.textColor = .white
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            self.label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.label.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.frame.height * 0.15),
        ])
    }
}
