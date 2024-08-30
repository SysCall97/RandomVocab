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
        self.addMarkAsFavouriteButton()
        self.addPhoneticsLabel()
        self.addPhoneticsButton()
        self.addButtons()
        self.addMeaningView()
    }
}

//MARK: private functions
extension ViewController {
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
        self.label = UILabel()
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
    
    private func addMarkAsFavouriteButton() {
        markAsFavouriteButton = UIButton()
        markAsFavouriteButton.backgroundColor = .clear
        markAsFavouriteButton.tintColor = .yellow
        markAsFavouriteButton.addTarget(self, action: #selector(toggleFavouriteStatus), for: .touchUpInside)
        markAsFavouriteButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(markAsFavouriteButton)
        
        NSLayoutConstraint.activate([
            markAsFavouriteButton.centerYAnchor.constraint(equalTo: self.label.centerYAnchor),
            markAsFavouriteButton.leadingAnchor.constraint(equalTo: self.label.trailingAnchor, constant: 5),
            markAsFavouriteButton.heightAnchor.constraint(equalToConstant: 30),
            markAsFavouriteButton.widthAnchor.constraint(equalToConstant: 30)
        ])
        
    }
    
    private func addPhoneticsLabel() {
        self.phoneticsLabel = UILabel()
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
    
    private func addPhoneticsButton() {
        self.speakerButton = UIButton()
        self.speakerButton.backgroundColor = .clear
        self.speakerButton.setImage(UIImage(systemName: "speaker.2.fill"), for: .normal)
        self.speakerButton.addTarget(self, action: #selector(sparkerButtonPressed), for: .touchUpInside)
        self.speakerButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(speakerButton)
        
        NSLayoutConstraint.activate([
            self.speakerButton.centerYAnchor.constraint(equalTo: self.phoneticsLabel.centerYAnchor),
            self.speakerButton.leadingAnchor.constraint(equalTo: self.phoneticsLabel.trailingAnchor, constant: 5),
            self.speakerButton.heightAnchor.constraint(equalToConstant: 30),
            self.speakerButton.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func addButtons() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.previousButton = UIButton(type: .system)
        self.previousButton.setTitle("< Prev", for: .normal)
        self.previousButton.setTitleColor(.white, for: .normal)
        self.previousButton.layer.borderWidth = 1
        self.previousButton.layer.borderColor = UIColor.white.cgColor
        self.previousButton.layer.cornerRadius = 7
        self.previousButton.translatesAutoresizingMaskIntoConstraints = false
        self.previousButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        self.previousButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.previousButton.addTarget(self, action: #selector(prevButtonPressed), for: .touchUpInside)
        
        self.nextButton = UIButton(type: .system)
        self.nextButton.setTitle("Next >", for: .normal)
        self.nextButton.setTitleColor(.white, for: .normal)
        self.nextButton.layer.borderWidth = 1
        self.nextButton.layer.borderColor = UIColor.white.cgColor
        self.nextButton.layer.cornerRadius = 7
        self.nextButton.translatesAutoresizingMaskIntoConstraints = false
        self.nextButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        self.nextButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)

        stackView.addArrangedSubview(previousButton)
        stackView.addArrangedSubview(nextButton)

        self.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            stackView.heightAnchor.constraint(equalToConstant: 44) // This constraint ensures the stack view height matches the buttons
        ])
    }
    
    private func addMeaningView() {
        let scrollViewContainerView: UIView = UIView()
        self.meaningsContainerScrollView = UIScrollView()
        scrollViewContainerView.addSubview(self.meaningsContainerScrollView)
        self.view.addSubview(scrollViewContainerView)
        
        
        scrollViewContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.meaningsContainerScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollViewContainerView.topAnchor.constraint(equalTo: self.phoneticsLabel.bottomAnchor, constant: 10.0),
            scrollViewContainerView.bottomAnchor.constraint(equalTo: self.previousButton.topAnchor, constant: -10.0),
            scrollViewContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollViewContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            self.meaningsContainerScrollView.topAnchor.constraint(equalTo: scrollViewContainerView.topAnchor),
            self.meaningsContainerScrollView.bottomAnchor.constraint(equalTo: scrollViewContainerView.bottomAnchor),
            self.meaningsContainerScrollView.leadingAnchor.constraint(equalTo: scrollViewContainerView.leadingAnchor),
            self.meaningsContainerScrollView.trailingAnchor.constraint(equalTo: scrollViewContainerView.trailingAnchor)
        ])
    }
}
