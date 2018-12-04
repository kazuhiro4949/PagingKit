//
//  NavigationBarViewController.swift
//  iOS Sample
//
//  Copyright (c) 2018 Kazuhiro Hayashi
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

class NavigationBarViewController: UIViewController {
    
    
    lazy var menuView: PagingMenuView = {
        let menuView = PagingMenuView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        menuView.dataSource = self
        menuView.menuDelegate = self
        menuView.cellAlignment = .center
        menuView.register(nib: UINib(nibName: "NavigationBarMenuCell", bundle: nil), with: "identifier")
        menuView.registerFocusView(nib: UINib(nibName: "NavigationBarFocusView", bundle: nil))
        return menuView
    }()
    var contentViewController: PagingContentViewController?
    
    
    let dataSource: [(menu: String, content: UIViewController)] = ["Martinez", "Alfred"].map {
        let title = $0
        let vc = UIStoryboard(name: "ContentTableViewController", bundle: nil).instantiateInitialViewController() as! ContentTableViewController
        return (menu: title, content: vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuView.reloadData()
        contentViewController?.reloadData()

        navigationItem.titleView = menuView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
            contentViewController?.delegate = self
            contentViewController?.dataSource = self
        }
    }
}

extension NavigationBarViewController: PagingMenuViewDataSource {
    func numberOfItemForPagingMenuView() -> Int {
        return dataSource.count
    }
    
    func pagingMenuView(pagingMenuView: PagingMenuView, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = pagingMenuView.dequeue(with: "identifier") as! NavigationBarMenuCell
        cell.titleLabel.text = dataSource[index].menu
        cell.backgroundColor = .clear
        return cell
    }
    
    func pagingMenuView(pagingMenuView: PagingMenuView, widthForItemAt index: Int) -> CGFloat {
        return 100
    }
}

extension NavigationBarViewController: PagingMenuViewDelegate {
    func pagingMenuView(pagingMenuView: PagingMenuView, didSelectItemAt index: Int) {
        menuView.scroll(index: index, completeHandler: { _  in })
        contentViewController?.scroll(to: index, animated: true)
    }
}

extension NavigationBarViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return dataSource[index].content
    }
}

extension NavigationBarViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        menuView.scroll(index: index, percent: percent)
    }
}

