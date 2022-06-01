//
//  APICaller.swift
//  InterCoV-19
//
//  Created by Deka Primatio on 30/05/22.
//

import Foundation

extension DateFormatter {
    // Convert string date dari API dan convert menjadi date object
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        formatter.timeZone = .current
        formatter.locale = .current
        return formatter
    }()
    
    // Convert date agar bisa digabung nanti
    static let prettyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeZone = .current
        formatter.locale = .current
        return formatter
    }()
}

class APICaller{
    
    // variabel shared agar bisa dipanggil tanpa harus memanggil built-in method untuk setiap pemanggilan API
    // digunakan ketika melakukan fetch data API
    static let shared = APICaller()
    
    private init() {}
    
    // sumber API
    private struct Constants{
        static let allStatesUrl = URL(string: "https://api.covidtracking.com/v2/states.json")
    }
    
    // Scope data yang diambil
    enum DataScope{
        case national // Mengambil data nasional
        case state(State) // Mengambil data daerah dari objek State
    }
    
    // fungsi untuk mendapatkan data
    public func getCovidData(for scope: DataScope, completion: @escaping (Result<[DayData], Error>) -> Void) {
        let urlString: String
        switch scope {
        case .national:
            urlString = "https://api.covidtracking.com/v2/us/daily.json"
        case .state(let state):
            urlString =  "https://api.covidtracking.com/v2/states/\(state.state_code.lowercased())/daily.json"
        }
        
        // variable url yang tidak boleh kosong
        guard let url = URL(string: urlString) else { return }
        
        // perintah untuk mengambil data dari API berdasarkan data kasus harian
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            
            // Decode JSON data kasus harian format menjadi objek
            do {
                let result = try JSONDecoder().decode(CovidDataResponse.self, from: data)
                
                // Convert setiap models data
                let models: [DayData] = result.data.compactMap{
                    // mengambil tanggal dan total dari setiap tanggal
                    guard let value = $0.cases.total.value,
                          let date = DateFormatter.dayFormatter.date(from: $0.date) else{
                        return nil
                    }
                    
                    // menampilkan data tanggal dan total kasusnya
                    return DayData(
                        date: date,
                        count: value
                    )
                }
                
                completion(.success(models))
            }
            catch{
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // perintah untuk mengambil data dari API berdasarkan data tiap States
    public func getStateList(completion: @escaping (Result<[State], Error>) -> Void) {
        guard let url = Constants.allStatesUrl else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            
            // untuk menampilkan data kasus tiap States
            do {
                // Decode JSON data States format menjadi objek
                let result = try JSONDecoder().decode(StateListResponse.self, from: data)
                let states = result.data
                completion(.success(states))
            }
            catch{
                completion(.failure(error))
            }
        }
        
        task.resume()
        
    }
}

// MARK: - Codable Models dari API
// Semua let yang ada disini diambil dari bentuk JSON data yang tersedia pada API
// Setiap hierarki harus dibuatkan Codable datanya

struct StateListResponse: Codable{
    let data: [State]
}

struct State: Codable{
    let name: String
    let state_code: String
}

struct CovidDataResponse: Codable {
    let data: [CovidDayData]
}

struct CovidDayData: Codable {
    let cases: CovidCases
    let date: String
}

struct CovidCases: Codable {
    let total: TotalCases
}

struct TotalCases: Codable {
    let value: Int?
}

struct DayData {
    let date: Date
    let count: Int
}
