//
//  ViewController.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 28/7/24.
//

import UIKit

class ViewController: UIViewController {
    
    internal var label: UILabel!
    internal var phoneticsLabel: UILabel!
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
        DispatchQueue.main.async {
            self.label.text = model.word
            if let phonetics = model.phonetics {
                self.phoneticsLabel.text = phonetics.text
            } else {
                self.phoneticsLabel.text = ""
            }
        }
    }
}
