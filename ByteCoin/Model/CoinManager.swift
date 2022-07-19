//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Yarema Zaiachuk on 02.12.2021.bre
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdatePric(price: String, currency: String)
    func didFailWithError(error: Error)
}


struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "D1D42C5D-1733-4595-A2F2-049FF3A7C6D0"
    
    let currencyArray = ["USD","PLN","EUR","CNY","JPY","AUD","CHF","GBP","SEK","DKK","RUB","CAD","THB","UAH"]
    
    func getCoinPrice(for currency: String) {
        
        
        //Use String concatenation to add the selected currency at the end of the baseURL.
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        
        //Use optional binding to unwrap the URL that's created from the urlString
        if let url = URL(string: urlString) {
            
            //Create a new URLSession object with default configuration.
            let session = URLSession(configuration: .default)
            
            //Create a new data task for the URLSession
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                //Format the data we got back as a string to be able to print it.
                if let safeData = data {
                    if let bitcoinPrice = self.parceJSON(safeData){
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        self.delegate?.didUpdatePric(price: priceString, currency: currency)
                    }
                }
            }
            //Start task to fetch data from bitcoin average's servers.
            task.resume()
        }
    }
    
    func parceJSON(_ data: Data) -> Double? {
       
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodeData.rate
            print(lastPrice)
            return lastPrice
            
        } catch {
            delegate?.didFailWithError(error: error)
            print(error)
            return nil
        }
    }
}
