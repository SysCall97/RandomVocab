//
//  ViewController.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 28/7/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    internal var label: UILabel!
    internal var phoneticsLabel: UILabel!
    internal var speakerButton: UIButton!
    private var audioPlayer: AVPlayer?
    private var audioLink: String?
    private var currentModel: WordModel?
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
//        self.renderNextWord()
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
        if let currentModel {
            wordManager.markedAsFavourite(currentModel)
        }
    }
}

//MARK: private functions
extension ViewController {
    private func renderNextWord() {
        Task {
            guard let model: WordModel = await wordManager.getNextWord() else {
                return
            }
            self.renderViews(with: model)
        }
    }
    
    private func renderPrevWord() {
        Task {
            guard let model: WordModel = await wordManager.getPrevWord() else {
                return
            }
            self.renderViews(with: model)
        }
    }
    
    private func renderViews(with model: WordModel) {
        self.currentModel = model
        DispatchQueue.main.async {
            self.label.text = model.word
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
        }
    }
}
