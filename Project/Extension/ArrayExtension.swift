//
//  ArrayExtension.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-29.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

extension Array where Element == Band {
    init(fileName: String) throws {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw Band.DecodingError.missingFile
        }
        
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: url)
        self = try decoder.decode([Band].self, from: data)
    }
    
//    init(url: String) throws {
//        
//        let configuration = URLSessionConfiguration.ephemeral
//        let session = URLSession(configuration: configuration)
//        
//        guard let url = URL(string: url) else {
//            throw Band.DecodingError.missingFile
//        }
//        
//        let task = session.dataTask(with: url) {
//          
//            (data, response, error) in
//          
//                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
//                    throw Band.DecodingError.missingFile
//                }
//                  
//                do {
//                    let decoder = JSONDecoder()
//                    let data = try Data(contentsOf: url)
//                    self = try decoder.decode([Band].self, from: data)
//                    
//                } catch {
//                    self = []
//                    print("Error info: \(error)")
//                }
//        }
//        task.resume()
//        
//    }
}
