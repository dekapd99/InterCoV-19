//
//  FilterViewController.swift
//  InterCoV-19
//
//  Created by Deka Primatio on 30/05/22.
//

import UIKit


// filterviewcontroller adalah tampilan ui pada halaman States
class FilterViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    public var completion: ((State) -> Void)?
    
    // return filter ke dalam filterviewcontroller
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    // memproses data state dari api di main thread
    private var states: [State] = []{
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // fungsi utama penampilan halaman load data
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Choose State"
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        fetchStates()
        
        // tombol close
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // fetch data sattes
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
    
    // selector ketika user menekan tombol close dimana akan menutup pop up halaman States
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table
    
    // fungsi menampilkan hasil dari states berdasarkan seluruh jumlah states yang ada
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return states.count
    }

    // fungsi yang menampilkan hasil nama states di masing-masing cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let state = states[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = state.name
        return cell
    }
    
    // fungsi ketika menekan salah satu states
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // call completion handler
        let state = states[indexPath.row]
        completion?(state)
        
        // ketika menekan salah satu states maka akan menutup halaman States
        dismiss(animated: true, completion: nil)
    }
}
