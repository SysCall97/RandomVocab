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
        self.addPhoneticsLabel()
        self.addButtons()
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
        self.label.font = UIFont.systemFont(ofSize: 35, weight: UIFont.Weight(510.0))
        self.label.textColor = .white
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            self.label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.label.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.frame.height * 0.15),
        ])
    }
    
    private func addPhoneticsLabel() {
        self.phoneticsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20))
        self.phoneticsLabel.text = "Hello everyone"
        self.phoneticsLabel.numberOfLines = 1
        self.phoneticsLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.light)
        self.phoneticsLabel.textColor = .white
        self.phoneticsLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(phoneticsLabel)
        
        NSLayoutConstraint.activate([
            self.phoneticsLabel.topAnchor.constraint(equalTo: self.label.bottomAnchor, constant: 0),
            self.phoneticsLabel.leadingAnchor.constraint(equalTo: self.label.leadingAnchor, constant: 0)
        ])
    }
    
    private func addButtons() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let prevButton = UIButton(type: .system)
        prevButton.setTitle("< Prev", for: .normal)
        prevButton.setTitleColor(.white, for: .normal)
        prevButton.layer.borderWidth = 1
        prevButton.layer.borderColor = UIColor.white.cgColor
        prevButton.layer.cornerRadius = 7
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        prevButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        prevButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        prevButton.addTarget(self, action: #selector(prevButtonPressed), for: .touchUpInside)
        
        let nextButton = UIButton(type: .system)
        nextButton.setTitle("Next >", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.borderWidth = 1
        nextButton.layer.borderColor = UIColor.white.cgColor
        nextButton.layer.cornerRadius = 7
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)

        stackView.addArrangedSubview(prevButton)
        stackView.addArrangedSubview(nextButton)

        self.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            stackView.heightAnchor.constraint(equalToConstant: 44) // This constraint ensures the stack view height matches the buttons
        ])
    }
}
