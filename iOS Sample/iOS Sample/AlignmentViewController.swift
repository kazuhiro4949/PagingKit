//
//  DynamicSizeViewController.swift
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
import PagingKit

class AlignmentViewController: UIViewController {
    var menuViewController: PagingMenuViewController!
    var contentViewController: PagingContentViewController!

    var dataSource = [(menu: String, content: UIViewController)]() {
        didSet {
            menuViewController.reloadData()
            contentViewController.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuViewController.cellAlignment = .left
        menuViewController.register(type: TitleLabelMenuViewCell.self, forCellWithReuseIdentifier: "identifier")
        menuViewController.registerFocusView(view: UnderlineFocusView())

        dataSource = makeDataSource()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController.dataSource = self
            menuViewController.delegate = self
        } else if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
            contentViewController.delegate = self
            contentViewController.dataSource = self
        }
    }
    @IBAction func switchMenuButtonDidTap(sender: UIBarButtonItem) {
        switch menuViewController.menuView.cellAlignment {
        case .left:
            menuViewController.menuView.cellAlignment = .center
        case .center:
            menuViewController.menuView.cellAlignment = .right
        case .right:
            menuViewController.menuView.cellAlignment = .left
        }
        menuViewController.reloadData()
    }

    private func makeDataSource() -> [(menu: String, content: UIViewController)] {
        let menu = ["Martinez", "Alfred", "Louis"]
        
        return menu.map {
            let title = $0
            let vc = UIStoryboard(name: "ContentTableViewController", bundle: nil).instantiateInitialViewController() as! ContentTableViewController
            return (menu: title, content: vc)
        }
    }
}

extension AlignmentViewController: PagingMenuViewControllerDataSource {
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "identifier", for: index)  as! TitleLabelMenuViewCell
        cell.titleLabel.text = dataSource[index].menu
        return cell
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        return 90
    }
    
    
    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return dataSource.count
    }
}

extension AlignmentViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt Index: Int) -> UIViewController {
        return dataSource[Index].content
    }
}

extension AlignmentViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        contentViewController.scroll(to: page, animated: true)
    }
}

extension AlignmentViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        menuViewController.scroll(index: index, percent: percent, animated: false)
    }
}

