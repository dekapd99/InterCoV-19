//
//  FilterViewController.swift
//  InterCoV-19
//
//  Created by Deka Primatio on 30/05/22.
//

import UIKit

class FilterViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    public var completion: ((State) -> Void)?
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var states: [State] = []{
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Pilih Daerah"
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        fetchStates()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func fetchStates(){
        APICaller.shared.getStateList { [weak self] result in
            switch result{
            case .success(let states):
                self?.states = states
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - @objc
    
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return states.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let state = states[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = state.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // call completion handler
        let state = states[indexPath.row]
        completion?(state)
        
        // dismiss
        dismiss(animated: true, completion: nil)
    }
}
