//
//  ViewController.swift
//  InterCoV-19
//
//  Created by Deka Primatio on 30/05/22.
//

import UIKit


// Data Kasus Covid
class ViewController: UIViewController {
    
    /*
     - Call APIs
     - ViewModel
     - View: Table
     - Filter / User Bisa memilih Daerah dari Data di API
     - Update UI
     */
    
    // Membuat default data yang ditampilkan berdasarkan data nasional
    private var scope: APICaller.DataScope = .national

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Kasus Covid"
        createFilterButton()
        fetchData()
    }
    
    private func fetchData() {
        APICaller.shared.getCovidData(for: scope) { result in
            switch result {
            case.success(let data):
                break
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func createFilterButton(){
        
        let buttonTitle: String = {
            switch scope{
            case .national: return "Nasional"
            case .state(let state): return state.name
            }
        }()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: buttonTitle, style: .done, target: self, action: #selector(didTapFilter))
    }
    
    // MARK: - @objc
    @objc private func didTapFilter(){
        let vc = FilterViewController()
        vc.completion = { [weak self] state in
            self?.scope = .state(state)
            self?.fetchData()
            self?.createFilterButton()
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }

}
