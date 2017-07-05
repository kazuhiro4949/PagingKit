//
//  ContentViewController.swift
//  iOS Sample
//
//  Created by Kazuhiro Hayashi on 7/4/17.
//  Copyright © 2017 Kazuhiro Hayashi. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {

    var number: String?
    
    @IBOutlet weak var numberLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        numberLabel.text = number
        // Do any additional setup after loading the view.
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
