//
//  APICaller.swift
//  InterCoV-19
//
//  Created by Deka Primatio on 30/05/22.
//

import Foundation

class APICaller{
    static let shared = APICaller()
    
    private init() {
    }
    
    private struct Constants{
        static let allStatesUrl = URL(string: "https://api.covidtracking.com/v2/states.json")
    }
    
    enum DataScope{
        case national // Mengambil data nasional
        case state(State) // Mengambil data daerah dari objek State
    }
    
    public func getCovidData(for scope: DataScope, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString: String
        switch scope {
        case .national:
            urlString = "https://api.covidtracking.com/v2/us/daily.json"
        case .state(let state):
            urlString =  "https://api.covidtracking.com/v2/states/\(state.state_code.lowercased())/daily.json"
        }
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print(result)
            }
            catch{
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    public func getStateList(completion: @escaping (Result<[State], Error>) -> Void) {
        guard let url = Constants.allStatesUrl else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
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

// MARK: - Models

struct StateListResponse: Codable{
    let data: [State]
}

struct State: Codable{
    let name: String
    let state_code: String
}
