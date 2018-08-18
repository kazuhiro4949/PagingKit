//
//  InitializingWithoutStoryboardViewController.swift
//  iOS Sample
//
//  Created by Kazuhiro Hayashi on 2018/08/18.
//  Copyright © 2018 Kazuhiro Hayashi. All rights reserved.
//

import UIKit
import PagingKit

class InitializingWithoutStoryboardViewController: UIViewController {
    let contentViewController = PagingContentViewController()
    let menuViewController = PagingMenuViewController()
    
    
    let dataSource: [(menu: String, content: UIViewController)] = ["Martinez", "Alfred", "Louis", "Justin"].map {
        let title = $0
        let vc = UIStoryboard(name: "ContentTableViewController", bundle: nil).instantiateInitialViewController() as! ContentTableViewController
        return (menu: title, content: vc)
    }
    
    lazy var firstLoad: (() -> Void)? = { [weak self, menuViewController, contentViewController] in
        menuViewController.reloadData()
        contentViewController.reloadData()
        self?.firstLoad = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        firstLoad?()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            menuViewController.view.translatesAutoresizingMaskIntoConstraints = false
            addChildViewController(menuViewController)
            view.addSubview(menuViewController.view)
            menuViewController.didMove(toParentViewController: self)
            
            if #available(iOS 11.0, *) {
                view.addConstraints([
                    view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: menuViewController.view.topAnchor),
                    view.safeAreaLayoutGuide.leftAnchor.constraint(equalTo: menuViewController.view.leftAnchor),
                    view.safeAreaLayoutGuide.rightAnchor.constraint(equalTo: menuViewController.view.rightAnchor)
                    ])
                
                menuViewController.view
                    .heightAnchor
                    .constraint(equalToConstant: 44)
                    .isActive = true
            } else {
                fatalError("works only ios 11.0~")
            }
            
            menuViewController.delegate = self
            menuViewController.dataSource = self
        }
        
        do {
            contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
            addChildViewController(contentViewController)
            view.addSubview(contentViewController.view)
            contentViewController.didMove(toParentViewController: self)
            
            if #available(iOS 11.0, *) {
                view.addConstraints([
                    view.safeAreaLayoutGuide.leftAnchor.constraint(equalTo: contentViewController.view.leftAnchor),
                    view.safeAreaLayoutGuide.rightAnchor.constraint(equalTo: contentViewController.view.rightAnchor),
                    view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: contentViewController.view.bottomAnchor),
                    ])
                
                
                contentViewController.view
                    .topAnchor
                    .constraint(equalTo: menuViewController.view.bottomAnchor)
                    .isActive = true
            } else {
                fatalError("works only ios 11.0~")
            }

            
            contentViewController.delegate = self
            contentViewController.dataSource = self
        }
        
        menuViewController.register(type: TitleLabelMenuViewCell.self, forCellWithReuseIdentifier: "identifier")
        menuViewController.registerFocusView(view: UnderlineFocusView())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension InitializingWithoutStoryboardViewController: PagingMenuViewControllerDataSource {
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "identifier", for: index)  as! TitleLabelMenuViewCell
        cell.titleLabel.text = dataSource[index].menu
        return cell
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        return viewController.view.bounds.width / CGFloat(dataSource.count)
    }
    
    var insets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets
        } else {
            return .zero
        }
    }
    
    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return dataSource.count
    }
}

extension InitializingWithoutStoryboardViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return dataSource[index].content
    }
}

extension InitializingWithoutStoryboardViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        contentViewController.scroll(to: page, animated: true)
    }
}

extension InitializingWithoutStoryboardViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        menuViewController.scroll(index: index, percent: percent, animated: false)
    }
}
