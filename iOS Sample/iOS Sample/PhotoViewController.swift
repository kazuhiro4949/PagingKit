//
//  PhotoViewController.swift
//  iOS Sample
//
//  Created by kahayash on 2017/10/28.
//  Copyright © 2017年 Kazuhiro Hayashi. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    var image: UIImage?
    
    @IBOutlet private weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
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
