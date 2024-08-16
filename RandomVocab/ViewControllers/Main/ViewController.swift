//
//  ViewController.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 28/7/24.
//

import UIKit

class ViewController: UIViewController {
    
    internal var label: UILabel!
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
        self.nextButtonPressed()
    }


}

//MARK: Button actions
extension ViewController {
    @objc
    internal func prevButtonPressed() {
        Task {
            guard let model: WordModel = await wordManager.getPrevWord() else {
                return
            }
            DispatchQueue.main.async {
                self.label.text = model.word
            }
        }
    }
    
    @objc
    internal func nextButtonPressed() {
        Task {
            guard let model: WordModel = await wordManager.getNextWord() else {
                return
            }
            DispatchQueue.main.async {
                self.label.text = model.word
            }
        }
    }
}
