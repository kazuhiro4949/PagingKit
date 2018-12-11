//
//  ContentTableViewController.swift
//  iOS Sample
//
//  Copyright (c) 2017 Kazuhiro Hayashi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

class ContentTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ContentTableViewCell
        cell.configure(data: data[indexPath.row])
        return cell
    }


    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        guard let tableViewLayoutMargin = tableViewLayoutMargin else { return }
        
        tableView.layoutMargins = tableViewLayoutMargin
    }

    /// To support safe area, all tableViews aligned on scrollView needs to be set margin for the cell's contentView and separator.
    @available(iOS 11.0, *)
    private var tableViewLayoutMargin: UIEdgeInsets? {
        guard let superview = parent?.view else {
            return nil
        }
        
        let defaultTableContentInsetLeft: CGFloat = 16
        return UIEdgeInsets(
            top: 0,
            left: superview.safeAreaInsets.left + defaultTableContentInsetLeft,
            bottom: 0,
            right: 0
        )
    }
}
