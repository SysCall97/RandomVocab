//
//  ViewController.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 28/7/24.
//

import UIKit
import AVFoundation
import Combine

@MainActor
class ViewController: UIViewController {
    static let storyboardName = "Main"
    static let storyboardIdentifier = "ViewController"
    
    internal var label: UILabel!
    internal var phoneticsLabel: UILabel!
    internal var speakerButton: UIButton!
    internal var markAsFavouriteButton: UIButton!
    internal var nextButton: UIButton!
    internal var previousButton: UIButton!
    internal var meaningsContainerScrollView: UIScrollView!
    private var audioPlayer: AVPlayer?
    private var audioLink: String?
    private var currentViewModel: WordViewModel?
    private var cancellable: AnyCancellable?
    var wordManager: AnyWordManager!
    
//    init(wordManager: AnyWordManager = WordManager()) {
//        self.wordManager = wordManager
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        self.wordManager = WordManager()
//        super.init(coder: coder)
//    }
    
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
    internal func toggleFavouriteStatus() {
        Task {
            if let currentViewModel {
                if currentViewModel.isMarkedAsFavourite {
                    await wordManager.unmarkAsFavourite(currentViewModel)
                } else {
                    await wordManager.markAsFavourite(currentViewModel)
                }
            }
        }
    }
    
    @objc
    internal func seeFavouriteWordsButtonPressed() {
        Task {
            let favouriteWordsVC = UIStoryboard(name: FavouriteWordsVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: FavouriteWordsVC.storyboardIdentifier) as! FavouriteWordsVC
            favouriteWordsVC.wordManager = self.wordManager
            self.modalPresentationStyle = .formSheet
            self.present(favouriteWordsVC, animated: true)
        }
    }
}

//MARK: private functions
extension ViewController {
    private func renderNextWord() {
        Task.detached { [weak self] in
            if let weakSelf = self {
                guard let model: WordViewModel = await weakSelf.wordManager.getNextWord() else {
                    return
                }
                await weakSelf.renderViews(with: model)
            }
        }
    }
    
    private func renderPrevWord() {
        Task.detached { [weak self] in
            if let weakSelf = self {
                guard let model: WordViewModel = await weakSelf.wordManager.getPrevWord() else {
                    return
                }
                await weakSelf.renderViews(with: model)
            }
        }
    }
    
    private func renderViews(with viewModel: WordViewModel) {
        self.currentViewModel = viewModel
        cancellable = currentViewModel?.$isMarkedAsFavourite.sink { [self] newValue in
            Task {
                await self.markAsFavouriteUpdated(to: newValue)
            }
        }
        let model = viewModel.wordModel
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
        Task {
            let isLastWord = await wordManager.isLastWord()
            if isLastWord {
                self.nextButton.isUserInteractionEnabled = false
                self.nextButton.layer.opacity = 0.6
            }
            let isFirstWord = await wordManager.isFirstWord()
            if isFirstWord {
                self.previousButton.isUserInteractionEnabled = false
                self.previousButton.layer.opacity = 0.6
            }
        }
        
        self.render(meanings: model.meanings)
    }
    
    private func markAsFavouriteUpdated(to newValue: Bool) async {
        var starImage = UIImage(systemName: "star")?.withRenderingMode(.alwaysTemplate)
        if newValue {
            starImage = UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysTemplate)
        }
        await MainActor.run {
            markAsFavouriteButton.setImage(starImage, for: .normal)
        }
    }
    
    private func render(meanings: WordModel.Meanings) {
        meaningsContainerScrollView.subviews.forEach { $0.removeFromSuperview() }
        meaningsContainerScrollView.contentSize = .zero
        
        var currentYPosition: CGFloat = 0.0
        let labelSpacing: CGFloat = 10.0
        
        for meaning in meanings {
            if let firstDefinition = meaning.definitions.first {
                let label = UILabel()
                let text = "(\(meaning.partOfSpeech)): \(firstDefinition.definition)"
                
                let font = UIFont.systemFont(ofSize: 16, weight: .medium)
                let labelHeight = getLabelHeight(for: text, width: meaningsContainerScrollView.frame.width-20, font: font)
                
                label.frame = CGRect(x: 10, y: currentYPosition, width: meaningsContainerScrollView.frame.width, height: labelHeight)
                
                label.text = text
                label.textColor = .white
                label.backgroundColor = .clear
                label.textAlignment = .left
                label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                label.numberOfLines = 0
                
                meaningsContainerScrollView.addSubview(label)
                currentYPosition += labelHeight + labelSpacing
            }
        }
        
        meaningsContainerScrollView.contentSize = CGSize(width: meaningsContainerScrollView.frame.width, height: currentYPosition)
    }
    
    private func getLabelHeight(for text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let label = UILabel()
        label.text = text
        label.font = font
        label.numberOfLines = 0

        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        
        let textRect = text.boundingRect(
            with: maxSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        
        return ceil(textRect.height)
    }
}
