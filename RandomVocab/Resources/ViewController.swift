//
//  ViewController.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 28/7/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Task {
            do {
                let val = try await DictionaryAPINetworkService().getMeaning(for: "shipping")
                print(val.first?.phonetics.first?.text)
            } catch {
                print(error)
            }
        }
    }


}

