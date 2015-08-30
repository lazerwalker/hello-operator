//
//  ViewController.swift
//  Switchboard
//
//  Created by Mike Lazer-Walker on 8/24/15.
//  Copyright © 2015 Mike Lazer-Walker. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var callers: [CallerView]!
    @IBOutlet weak var operatorView: CallerView!

    let manager = GameManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
}

