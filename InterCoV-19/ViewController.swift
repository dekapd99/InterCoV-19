//
//  ViewController.swift
//  InterCoV-19
//
//  Created by Deka Primatio on 30/05/22.
//

import UIKit
import Charts

// Data Kasus Covid
class ViewController: UIViewController, UITableViewDataSource {
    
    
    /*
     - Call APIs
     - ViewModel
     - View: Table
     - Filter / User Bisa memilih Daerah dari Data di API
     - Update UI
     */
    
    // Format angka agar bisa terlihat seperti ini 1.000.0000
    static let numberFormmater: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = "."
        formatter.formatterBehavior = .default
        formatter.locale = .current
        return formatter
    }()
    
    // Table View UI
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    // Print data covid harian di main thread
    private var dayData: [DayData] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.createGraph()
            }
        }
    }
    
    // Membuat default data yang ditampilkan berdasarkan data nasional
    private var scope: APICaller.DataScope = .national

    // Main thread
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Covid Cases"
        configureTable() // display table
        createFilterButton() // filter daerah
        fetchData() // fetch data api
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds //supaya layout pas sama layar
    }
    
    // Framework graphs dari https://github.com/danielgindi/Charts
    private func createGraph() {
        
        // Header Graphs
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width/1.5))
        headerView.clipsToBounds = true //supaya layout pas sama layar
        
        let set = dayData.prefix(20) // menampilkan max 20 data terakhir
        var entries: [BarChartDataEntry] = [] //penampung data entries
        // menampilkan data dari dataset yang dimiliki
        for index in 0..<set.count{
            let data = set[index]
            entries.append(.init(x: Double(index), y: Double(data.count)))
        }
        
        let dataSet = BarChartDataSet(entries: entries)
        
        dataSet.colors = ChartColorTemplates.joyful() // warna graph
        
        let data: BarChartData = BarChartData(dataSet: dataSet)
        
        let chart = BarChartView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width/1.5)) // setting barchart
        
        chart.data = data //chart data diambil dari data
        
        headerView.addSubview(chart) //menampilkan header
        
        tableView.tableHeaderView = headerView
    }
    
    // fungsi konfigurasi table yang dimana akan ditampilkan dengan sendiri
    private func configureTable() {
        view.addSubview(tableView)
        tableView.dataSource = self
    }
    
    // fungsi fetch data-data dari api
    private func fetchData() {
        APICaller.shared.getCovidData(for: scope) { [weak self] result in
            switch result {
            case .success(let dayData):
                self?.dayData = dayData
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // fungsi memasukkan data api ke filter daerah
    private func createFilterButton(){
        // fungsi tombol state untuk menampilkan daerah
        let buttonTitle: String = {
            switch scope{
            case .national: return "State"
            case .state(let state): return state.name
            }
        }()
        // tombol state
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: buttonTitle, style: .done, target: self, action: #selector(didTapFilter))
    }
    
    // MARK: - @objc
    
    // fungsi selector ketika tombol state ditekan
    @objc private func didTapFilter(){
        let vc = FilterViewController()
        vc.completion = { [weak self] state in
            self?.scope = .state(state) // mengambil data state
            self?.fetchData() // fetch data yang diminta
            self?.createFilterButton() // filter daerah
        }
        
        // menampilkan daerah ke dalam ui
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    //MARK: - TABLE VIEW
    
    // fungsi yang menampilkan seluruh data berdasarkan perhitungan setiap data harian
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayData.count
    }
    
    // fungsi untuk menampilkan label default data dari tiap cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dayData[indexPath.row]
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = createText(with: data)
        return cell
    }

    // fungsi format bentuk text yang akan ditampilkan
    private func createText(with data: DayData) -> String? {
        let dateString = DateFormatter.prettyFormatter.string(from: data.date)
        let total = Self.numberFormmater.string(from: NSNumber(value: data.count))
        return "\(dateString): \(total ?? "\(data.count)")"
    }
}
