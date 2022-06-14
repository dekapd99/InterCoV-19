//
//  FilterViewController.swift
//  InterCoV-19
//
//  Created by Deka Primatio on 30/05/22.
//

import UIKit

// Halaman Filter States
class FilterViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    public var completion: ((State) -> Void)?
    
    // Tampilkan hasil filter ke Table Cell
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    // Hasil Fetch Data State di Main Thread
    private var states: [State] = []{
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData() // Reload Data
            }
        }
    }
    
    // Load Tampilan
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Choose State"
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        fetchStates() // Fungsi Fetch States
        
        // Tombol Close Halaman
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
    }
    
    // Fungsi Load Layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds // Frame sesuai ukuran layar
    }
    
    // Fetch Data States melalui fungsi getStateList di APIService.swift
    private func fetchStates(){
        APIService.shared.getStateList { [weak self] result in
            switch result{
            case .success(let states):
                self?.states = states
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - @objc
    
    // Selector Tombol Close ketika ditekan
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table View
    
    // Fungsi Menampilkan Data pada Table berdasarkan Jumlah States yang Ada
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return states.count
    }

    // Fungsi untuk menampilkan Label Tabel Nama States
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let state = states[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = state.name
        return cell
    }
    
    // Fungsi Ketika Menekan Salah Satu States
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let state = states[indexPath.row]
        
        completion?(state) // Call completion handler
        // Ketika menekan salah satu states maka akan menutup halaman States
        dismiss(animated: true, completion: nil)
    }
}
