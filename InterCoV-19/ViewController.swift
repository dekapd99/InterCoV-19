//
//  ViewController.swift
//  InterCoV-19
//
//  Created by Deka Primatio on 30/05/22.
//

import UIKit
import Charts

// Tampilan Beranda Aplikasi
class ViewController: UIViewController, UITableViewDataSource {
    
    // Format angka agar bisa terlihat seperti ini -> 1.000.000
    static let numberFormmater: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = "."
        formatter.formatterBehavior = .default
        formatter.locale = .current
        return formatter
    }()
    
    // Buat tabel dari UITableView
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
    
    // Default: data yang ditampilkan berdasarkan data nasional
    private var scope: APIService.DataScope = .national

    // Load Tampilan Aplikasi
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Covid Cases"
        configureTable()        // display table
        createFilterButton()    // filter daerah
        fetchData()             // fetch data API
    }
    
    // Fungsi load layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds // Frame sesuai ukuran layar
    }
    
    // Framework graphs dari https://github.com/danielgindi/Charts
    private func createGraph() {
        
        // Header Graphs
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width/1.5))
        headerView.clipsToBounds = true //supaya layout pas sama ukuran layar
    
        let set = dayData.prefix(20) // Tampilkan max 20 data terakhir
        var entries: [BarChartDataEntry] = [] // Penampung data entries
        
        // Tampilkan data dari dataset index
        for index in 0..<set.count{
            let data = set[index]
            entries.append(.init(x: Double(index), y: Double(data.count)))
        }
        
        let dataSet = BarChartDataSet(entries: entries) // penampungan dataset
        
        dataSet.colors = ChartColorTemplates.joyful() // warna graph
        
        let data: BarChartData = BarChartData(dataSet: dataSet) // Masukkan dataset ke dalam BarChart
        
        let chart = BarChartView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width/1.5)) // Setting Frame BarChart
        
        chart.data = data // Chart Data dibuat berdasarkan data yang tersimpan di API
        
        headerView.addSubview(chart) // HeaderView
        
        tableView.tableHeaderView = headerView // Tabel HeaderView
    }
    
    // Fungsi Tabel Konfigurasi Sumber Data
    private func configureTable() {
        view.addSubview(tableView)
        tableView.dataSource = self
    }
    
    // Fungsi Fetch Data API
    private func fetchData() {
        APIService.shared.getCovidData(for: scope) { [weak self] result in
            switch result {
            case .success(let dayData):
                self?.dayData = dayData
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // Fungsi Filter Button
    private func createFilterButton() {
        let buttonTitle: String = {
            switch scope{
            case .national: return "State"
            case .state(let state): return state.name
            }
        }()
        // Tombol Filter
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: buttonTitle, style: .done, target: self, action: #selector(didTapFilter))
    }
    
    // MARK: - @objc
    
    // Fungsi Selector ketika Tombol Filter di Tekan
    @objc private func didTapFilter(){
        let vc = FilterViewController()
        vc.completion = { [weak self] state in
            self?.scope = .state(state) // mengambil data state
            self?.fetchData() // fetch data yang diminta
            self?.createFilterButton() // filter daerah
        }
        
        // Menampilkan hasil filter daerah
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    //MARK: - TABLE VIEW
    
    // Fungsi Menampilkan Data pada Table berdasarkan Daily Data
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayData.count
    }
    
    // Fungsi untuk menampilkan Label Tabel
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dayData[indexPath.row]
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = createText(with: data)
        return cell
    }

    // Fungsi Format Text untuk Tanggal dan Angka Digit
    private func createText(with data: DayData) -> String? {
        let dateString = DateFormatter.prettyFormatter.string(from: data.date)
        let total = Self.numberFormmater.string(from: NSNumber(value: data.count))
        return "\(dateString): \(total ?? "\(data.count)")"
    }
}
