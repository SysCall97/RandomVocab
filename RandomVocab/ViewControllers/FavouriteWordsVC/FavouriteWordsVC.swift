//
//  FavouriteWordsVC.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 14/9/24.
//

import UIKit
import AVFoundation

class TableViewModel {
    let wordViewModel: WordViewModel
    var isOpened: Bool
    
    init(wordViewModel: WordViewModel, isOpened: Bool = false) {
        self.wordViewModel = wordViewModel
        self.isOpened = isOpened
    }
}

class FavouriteWordsVC: UIViewController {
    static let storyboardName = "FavouriteWordsVC"
    static let storyboardIdentifier = "FavouriteWordsVC"
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FavouriteWordCell.self, forCellReuseIdentifier: "FavouriteWordCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        return tableView
    }()
    
    var wordManager: AnyWordManager! {
        didSet {
            Task {
                let favWords = await wordManager.getFavouriteWords() ?? []
                favWords.forEach { wordViewModel in
                    self.tableViewModels.append(TableViewModel(wordViewModel: wordViewModel))
                }
                tableView.reloadData()
            }
        }
    }
    
    private var tableViewModels = [TableViewModel]()
    private var audioPlayer: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.frame = CGRect(x: 0, y: 40, width: Int(self.view.bounds.width), height: Int(self.view.bounds.height))
    }
}

extension FavouriteWordsVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        self.tableViewModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = tableViewModels[section]
        
        if section.isOpened {
            return section.wordViewModel.wordModel.meanings.count + 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FavouriteWordCell", for: indexPath) as! FavouriteWordCell
            cell.initCell(with: self.tableViewModels[indexPath.section].wordViewModel)
            cell.delegate = self
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = self.tableViewModels[indexPath.section].wordViewModel.wordModel.meanings[indexPath.row - 1].definitions.first?.definition
        cell.backgroundColor = .white
        return cell
    }
    
}

extension FavouriteWordsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            tableViewModels[indexPath.section].isOpened = !tableViewModels[indexPath.section].isOpened
            tableView.reloadSections([indexPath.section], with: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableViewModels[indexPath.section].isOpened {
            return .none
        }
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        Task {
            tableView.beginUpdates()
            let viewModel = tableViewModels[indexPath.section].wordViewModel
            print("DELETED:: \(viewModel.wordModel.word)")
            await self.wordManager.unmarkAsFavourite(viewModel)
            tableViewModels.remove(at: indexPath.section)
            
            tableView.deleteSections([indexPath.section], with: .fade)
            tableView.endUpdates()
        }
    }
}

extension FavouriteWordsVC: AnyFavouriteWordCellSpeakerDelegate {
    func speakerButtonPressed(for model: WordModel?) {
        if let audioLink = model?.phonetics?.audio {
            if let url = URL(string: audioLink) {
                audioPlayer = AVPlayer(url: url)
                audioPlayer?.play()
            }
        }
    }
    
    
}


protocol AnyFavouriteWordCellSpeakerDelegate {
    func speakerButtonPressed(for model: WordModel?)
}

class FavouriteWordCell: UITableViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.light)
        label.numberOfLines = 0
        return label
    }()
    
    let phoneticLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.light)
        return label
    }()
    
    let phoneticsButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.setImage(UIImage(systemName: "speaker.2.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(phoneticLabel)
        contentView.addSubview(phoneticsButton)
        phoneticsButton.addTarget(self, action: #selector(sparkerButtonPressed), for: .touchUpInside)
        contentView.backgroundColor = .lightGray
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            phoneticLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 5),
            phoneticLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            phoneticsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            phoneticsButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            phoneticsButton.heightAnchor.constraint(equalToConstant: 44),
            phoneticsButton.widthAnchor.constraint(equalToConstant: 44),
            
            // Make sure phoneticLabel doesn't go beyond phoneticsButton
            phoneticLabel.trailingAnchor.constraint(lessThanOrEqualTo: phoneticsButton.leadingAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var currentViewModel: WordViewModel?
    var delegate: AnyFavouriteWordCellSpeakerDelegate?
    
    func initCell(with viewModel: WordViewModel) {
        self.currentViewModel = viewModel
        
        self.titleLabel.text = viewModel.wordModel.word
        self.phoneticLabel.isHidden = true
        self.phoneticsButton.isHidden = true
        if let phonetics = viewModel.wordModel.phonetics {
            if let text = phonetics.text {
                self.phoneticLabel.text = text
                self.phoneticLabel.isHidden = false
            }
        }
        
        self.phoneticsButton.isHidden = !viewModel.isPhoneticsHasAudibleFile
        
    }
    
    @objc
    internal func sparkerButtonPressed() {
        self.delegate?.speakerButtonPressed(for: self.currentViewModel?.wordModel)
    }
    
}
