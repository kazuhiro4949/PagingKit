//
//  ContentTableViewController.swift
//  iOS Sample
//
//  Created by kahayash on 2017/10/13.
//  Copyright © 2017年 Kazuhiro Hayashi. All rights reserved.
//

import UIKit

class ContentTableViewController: UITableViewController {

    var data: [(emoji: String, name: String)] = [
        (emoji: "🐶", name: "Dog"),
        (emoji: "🐱", name: "Cat"),
        (emoji: "🦁", name: "Lion"),
        (emoji: "🐴", name: "Horse"),
        (emoji: "🐮", name: "Cow"),
        (emoji: "🐷", name: "Pig"),
        (emoji: "🐭", name: "Mouse"),
        (emoji: "🐹", name: "Hamster"),
        (emoji: "🐰", name: "Rabbit"),
        (emoji: "🐻", name: "Bear"),
        (emoji: "🐨", name: "Koala"),
        (emoji: "🐼", name: "Panda"),
        (emoji: "🐔", name: "Chicken"),
        (emoji: "🐤", name: "Baby"),
        (emoji: "🐵", name: "Monkey"),
        (emoji: "🦊", name: "Fox"),
        (emoji: "🐸", name: "Frog"),
        (emoji: "🦀", name: "Crab"),
        (emoji: "🦑", name: "Squid"),
        (emoji: "🐙", name: "Octopus"),
        (emoji: "🐬", name: "Dolphin"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ContentTableViewCell
        cell.configure(data: data[indexPath.row])
        return cell
    }


}
