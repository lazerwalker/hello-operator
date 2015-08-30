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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let names = ["Alice", "Bob", "Charlie", "Danzig", "Edgar", "Frank", "Gerald", "Harvey", "Irene", "Justice"]
        for var i=0; i<callers.count; i++ {
            let caller = callers[i]
            caller.name = names[i]
            if arc4random_uniform(2) == 0 {
                caller.turnOnLight()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

