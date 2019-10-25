//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

class BandListViewController: UITableViewController {

    var bands = BandList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //return the number of rows for this table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bands.bands.count
    }
    
    //executed for each cell on the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //get the reusable cell with identifier BandCellItem
        let cell = tableView.dequeueReusableCell(withIdentifier: "BandCellItem", for: indexPath)
        //get band related to table row position
        let band = bands.bands[indexPath.row]
        
        if let label = cell.viewWithTag(1000) as? UILabel {
            label.text = band.name
        }
        if let image = cell.viewWithTag(1001) as? UIImageView {
            image.load(url: URL(string: band.pictures[0])!)
        }
        if let genre = cell.viewWithTag(1002) as? UILabel {
            let genres = band.genres.map({
                $0.rawValue
            })
            genre.text = "Genres: \(genres.joined(separator: ", "))"
        }
        if let location = cell.viewWithTag(1003) as? UIButton {
            var address = [band.address.city]
            if let state = band.address.state {
                address.append(state)
            } else {
                address.append(band.address.country)
            }
            location.setTitle("\(address.joined(separator: " - "))", for: .normal)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowBandSegue" {
            if let bandViewController = segue.destination as? BandViewController {
                if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                    let item = bands.bands[indexPath.row]
                    bandViewController.band = item
                }
            }
        }
    }
    
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
