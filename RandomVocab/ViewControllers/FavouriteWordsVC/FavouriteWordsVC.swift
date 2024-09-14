//
//  FavouriteWordsVC.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 14/9/24.
//

import UIKit

class FavouriteWordsVC: UIViewController {
    static let storyboardName = "FavouriteWordsVC"
    static let storyboardIdentifier = "FavouriteWordsVC"
    
    var wordManager: AnyWordManager! {
        didSet {
            Task {
                favWords = await wordManager.getFavouriteWords() ?? []
                self.favWords.forEach { wvm in
                    print(wvm.wordModel.word)
                }
            }
        }
    }
    
    private var favWords = [WordViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
