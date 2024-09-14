//
//  FavouriteWordsVC.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 14/9/24.
//

import UIKit

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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        if indexPath.row == 0 {
            cell.textLabel?.text = self.tableViewModels[indexPath.section].wordViewModel.wordModel.word
            cell.backgroundColor = .lightGray
            return cell
        } else {
            cell.textLabel?.text = self.tableViewModels[indexPath.section].wordViewModel.wordModel.meanings[indexPath.row - 1].definitions.first?.definition
            cell.backgroundColor = .white
        }
        
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
}
