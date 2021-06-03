//
//  RootSplitViewController.swift
//  Viewer App
//
//  Created by jeremie bitancor on 6/3/21.
//

import UIKit

class RootSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.
    }

}

//MARK: - UISplitViewController Delegate
/// Delegate for showing master view controller when the app first starts
extension RootSplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
