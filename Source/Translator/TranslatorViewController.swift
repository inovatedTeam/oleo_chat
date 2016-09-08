//
//  TranslatorViewController.swift
//  ready
//
//  Created by Patrick Sheehan on 4/14/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit

class TranslatorViewController: UIViewController {

    @IBOutlet var comingSoonLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Translator", comment: "Translator Title")
        comingSoonLabel.text = NSLocalizedString("Translator_Coming_Soon", comment: "Coming soon label")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
