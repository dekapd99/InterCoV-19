//
//  APIService.swift
//  InterCoV-19
//
//  Created by Deka Primatio on 30/05/22.
//

import Foundation

// Extension: Format Tanggal menjadi Standar Penulisan Tanggal di Swift
extension DateFormatter {
    // Convert string date dari API dan convert menjadi date object
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        formatter.timeZone = .current
        formatter.locale = .current
        return formatter
    }()
    
    // Convert Date
    static let prettyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeZone = .current
        formatter.locale = .current
        return formatter
    }()
}

// Fungsi Fetch API
class APIService{
    
    static let shared = APIService() // instance -> agar API Service bisa digunakan di project ini
    
    private init() {}
    
    // Base URL: Sumber API
    private struct Constants{
        static let allStatesUrl = URL(string: "https://api.covidtracking.com/v2/states.json")
    }
    
    // Data Declaration: Endpoints DataScope (2 Object Data -> national dan state)
    enum DataScope{
        case national
        case state(State)
    }
    
    // Fungsi get daily data untuk skala National dan States
    public func getCovidData(for scope: DataScope, completion: @escaping (Result<[DayData], Error>) -> Void) {
        let urlString: String
        switch scope {
        case .national:
            urlString = "https://api.covidtracking.com/v2/us/daily.json"
        case .state(let state):
            urlString =  "https://api.covidtracking.com/v2/states/\(state.state_code.lowercased())/daily.json"
        }
        
        guard let url = URL(string: urlString) else { return } // URL as String -> urlString
        
        // URL Session: Get Data
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            
            // Decode JSON data kasus harian format menjadi objek
            do {
                let result = try JSONDecoder().decode(CovidDataResponse.self, from: data)
                // Convert setiap daily data menjadi Models compactMap
                let models: [DayData] = result.data.compactMap{
                    // Get tanggal dan total dari setiap tanggal dan format tanggal tersebut
                    guard let value = $0.cases.total.value,
                          let date = DateFormatter.dayFormatter.date(from: $0.date) else{
                        return nil
                    }
                    // Menampilkan data tanggal dan total kasus
                    return DayData(
                        date: date,
                        count: value
                    )
                }
                completion(.success(models)) // Completion Sukses tampilkan Models
            }
            catch{
                completion(.failure(error)) // Completion Gagal tampilkan Error
            }
        }
        task.resume()
    }
    
    // Get data berdasarkan States
    public func getStateList(completion: @escaping (Result<[State], Error>) -> Void) {
        guard let url = Constants.allStatesUrl else { return }
        
        // URL Session: Get Data
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            
            // Decode JSON data States format menjadi objek States itu sendiri
            do {
                let result = try JSONDecoder().decode(StateListResponse.self, from: data)
                let states = result.data
                completion(.success(states)) // Completion Sukses tampilkan States
            }
            catch{
                completion(.failure(error)) // Completion Gagal tampilkan Error
            }
        }
        task.resume()
    }
}

// MARK: - Codable Models dari API
// Deklarasi Data yang digunakan dari API
// Semua let yang ada disini diambil dari bentuk JSON data yang tersedia pada API
// Setiap hierarki harus dibuatkan Codable Protocol

struct StateListResponse: Codable{
    let data: [State]
}

struct State: Codable {
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
