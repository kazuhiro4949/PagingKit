//
//  SwiftUIViewController.swift
//  iOS Sample
//
//  Created by Kazuhiro Hayashi on 6/22/1 R.
//  Copyright © 2019 Kazuhiro Hayashi. All rights reserved.
//

import UIKit
#if canImport(SwiftUI)
import SwiftUI
#endif

class SwiftUIViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource = [
        "Simple"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectionIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SwiftUIViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifier", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
}

extension SwiftUIViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch dataSource[indexPath.row] {
        case "Simple":
            if #available(iOS 13, *) {
                let vc = UIHostingController(rootView: SimpleView())
                navigationController?.pushViewController(vc, animated: true)
            } else {
                // Fallback on earlier versions
            }
        default:
            break
        }
    }
}
