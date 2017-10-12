//
//  ArbitraryNumberViewController.swift
//  iOS Sample
//
//  Created by kahayash on 2017/07/18.
//  Copyright © 2017年 Kazuhiro Hayashi. All rights reserved.
//

import UIKit
import PagingKit

class ArbitraryNumberViewController: UIViewController {
    var contentViewController: PagingContentViewController!
    var menuViewController: PagingMenuViewController!
    
    var dataSource = [(menu: String, content: UIViewController)]()
    
    var startPosition = 0
    var isSegmentedMenu = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alertController = makeAlertController()
        present(alertController, animated: true, completion: nil)
        
        menuViewController?.register(nib: UINib(nibName: "MenuCell", bundle: nil), forCellWithReuseIdentifier: "identifier")
        menuViewController?.registerFocusView(nib: UINib(nibName: "FocusView", bundle: nil))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
}

// MARK:- PagingMenuViewControllerDataSource

extension ArbitraryNumberViewController: PagingMenuViewControllerDataSource {
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "identifier", for: index)  as! MenuCell
        cell.titleLabel.text = dataSource[index].menu
        return cell
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        if isSegmentedMenu {
            return UIScreen.main.bounds.width / CGFloat(dataSource.count)
        } else {
            MenuCell.sizingCell.titleLabel.text = dataSource[index].menu
            var referenceSize = UILayoutFittingCompressedSize
            referenceSize.height = viewController.view.bounds.height
            let size = MenuCell.sizingCell.systemLayoutSizeFitting(referenceSize)
            return size.width
        }
    }
    
    
    func numberOfItemForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return dataSource.count
    }
}

// MARK:- PagingContentViewControllerDataSource

extension ArbitraryNumberViewController: PagingContentViewControllerDataSource {
    func numberOfItemForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt Index: Int) -> UIViewController {
        return dataSource[Index].content
    }
}

// MARK:- PagingMenuViewControllerDelegate

extension ArbitraryNumberViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        contentViewController?.scroll(to: page, animated: true)
    }
}

// MARK:- PagingContentViewControllerDelegate

extension ArbitraryNumberViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        menuViewController?.scroll(index: index, percent: percent, animated: false)
    }
}

// MARK:- UITextFieldDelegate

extension ArbitraryNumberViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let number = textField.text.flatMap({ UInt($0) }) else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        if textField.tag == 0 {
            dataSource = (0..<number).map {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentViewController") as! ContentViewController
                vc.number = "\($0)"
                return (menu: "\($0)", content: vc)
            }
        } else if textField.tag == 1 {
            startPosition = Int(number)
        }
    }
}

// MARK:- fileprivate

extension ArbitraryNumberViewController {
    fileprivate func makeAlertController() -> UIAlertController {
        let alertController = UIAlertController(title: "Input number of pages", message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Create Scroll Menu", style: .`default`, handler: { [weak self] _ in
            guard let _self = self else { return }
            _self.isSegmentedMenu = false
            _self.menuViewController.reloadData(with: _self.startPosition)
            _self.contentViewController.reloadData(with: _self.startPosition)
        }))
        alertController.addAction(UIAlertAction(title: "Create Segmentation", style: .`default`, handler: { [weak self] _ in
            guard let _self = self else { return }
            _self.isSegmentedMenu = true
            _self.menuViewController.reloadData(with: _self.startPosition)
            _self.contentViewController.reloadData(with: _self.startPosition)
        }))
        alertController.addTextField { (textField) in
            textField.placeholder = "number of pages"
            textField.tag = 0
            textField.delegate = self
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "start index"
            textField.tag = 1
            textField.delegate = self
        }
        return alertController
    }
}
