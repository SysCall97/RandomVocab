//
//  ViewController.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 28/7/24.
//

import UIKit
import AVFoundation
import Combine

class ViewController: UIViewController {
    
    internal var label: UILabel!
    internal var phoneticsLabel: UILabel!
    internal var speakerButton: UIButton!
    internal var markAsFavouriteButton: UIButton!
    internal var nextButton: UIButton!
    internal var previousButton: UIButton!
    private var audioPlayer: AVPlayer?
    private var audioLink: String?
    private var currentViewModel: WordViewModel?
    private var cancellable: AnyCancellable?
    var wordManager: AnyWordManager
    
    init(wordManager: AnyWordManager = WordManager()) {
        self.wordManager = wordManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.wordManager = WordManager()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.initView()
        self.renderNextWord()
    }


}

//MARK: Button actions
extension ViewController {
    @objc
    internal func prevButtonPressed() {
        self.renderPrevWord()
    }
    
    @objc
    internal func nextButtonPressed() {
        self.renderNextWord()
    }
    
    @objc
    internal func sparkerButtonPressed() {
        if let audioLink = self.audioLink {
            if let url = URL(string: audioLink) {
                audioPlayer = AVPlayer(url: url)
                audioPlayer?.play()
            }
        }
    }
    
    @objc
    internal func markCurrentWordAsFavourite() {
        if let currentViewModel {
            wordManager.markedAsFavourite(currentViewModel)
        }
    }
}

//MARK: private functions
extension ViewController {
    private func renderNextWord() {
        Task {
            guard let model: WordViewModel = await wordManager.getNextWord() else {
                return
            }
            self.renderViews(with: model)
        }
    }
    
    private func renderPrevWord() {
        Task {
            guard let model: WordViewModel = await wordManager.getPrevWord() else {
                return
            }
            self.renderViews(with: model)
        }
    }
    
    private func renderViews(with viewModel: WordViewModel) {
        self.currentViewModel = viewModel
        cancellable = currentViewModel?.$isMarkedAsFavourite.sink { [weak self] newValue in
            if let weakSelf = self {
                weakSelf.markAsFavouriteUpdated(to: newValue)
            }
        }
        let model = viewModel.wordModel
        DispatchQueue.main.async { [self] in
            self.label.text = model.word
            
            if self.currentViewModel!.isMarkedAsFavourite {
                let starImage = UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysTemplate)
                markAsFavouriteButton.setImage(starImage, for: .normal)
            } else {
                let starImage = UIImage(systemName: "star")?.withRenderingMode(.alwaysTemplate)
                markAsFavouriteButton.setImage(starImage, for: .normal)
            }

            if let phonetics = model.phonetics {
                if let text = phonetics.text {
                    self.phoneticsLabel.text = text
                } else {
                    self.phoneticsLabel.text = ""
                }
                self.audioLink = phonetics.audio
                if let _ = phonetics.audio {
                    self.speakerButton.isHidden = false
                } else {
                    self.speakerButton.isHidden = true
                }
            } else {
                self.phoneticsLabel.text = ""
            }
            
            self.nextButton.isUserInteractionEnabled = true
            self.previousButton.isUserInteractionEnabled = true
            self.nextButton.layer.opacity = 1
            self.previousButton.layer.opacity = 1
            
            if viewModel.serialNo == CommonConstants.MAX_WORD_LIMIT {
                self.nextButton.isUserInteractionEnabled = false
                self.nextButton.layer.opacity = 0.6
            }
            if viewModel.serialNo == 1 {
                self.previousButton.isUserInteractionEnabled = false
                self.previousButton.layer.opacity = 0.6
            }
        }
    }
    
    private func markAsFavouriteUpdated(to newValue: Bool) {
        DispatchQueue.main.async { [self] in
            if newValue {
                let starImage = UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysTemplate)
                markAsFavouriteButton.setImage(starImage, for: .normal)
            } else {
                let starImage = UIImage(systemName: "star")?.withRenderingMode(.alwaysTemplate)
                markAsFavouriteButton.setImage(starImage, for: .normal)
            }
        }
    }
}
