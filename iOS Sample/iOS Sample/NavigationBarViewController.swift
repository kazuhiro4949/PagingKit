//
//  NavigationBarViewController.swift
//  iOS Sample
//
//  Created by kahayash on 2018/10/11.
//  Copyright © 2018年 Kazuhiro Hayashi. All rights reserved.
//

import UIKit
import PagingKit

class NavigationBarViewController: UIViewController {
    
    
    lazy var menuView: PagingMenuView = {
        let menuView = PagingMenuView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        menuView.dataSource = self
        menuView.menuDelegate = self
        menuView.cellAlignment = .center
        
        menuView.register(type: TitleLabelMenuViewCell.self, with: "identifier")
        menuView.registerFocusView(view: UnderlineFocusView())
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
        
        menuView.reloadData(with: 0)
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
        let cell = pagingMenuView.dequeue(with: "identifier") as! TitleLabelMenuViewCell
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

