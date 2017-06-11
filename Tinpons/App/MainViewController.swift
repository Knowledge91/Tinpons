//
//  MainViewController.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.16
//

import UIKit
import AWSMobileHubHelper

class MainViewController: UITableViewController {
    
    var demoFeatures: [DemoFeature] = []
    var willEnterForegroundObserver: AnyObject!
    fileprivate let loginButton: UIBarButtonItem = UIBarButtonItem(title: nil, style: .done, target: nil, action: nil)

    // MARK: - View lifecycle

    func onSignIn (_ success: Bool) {
        // handle successful sign in
        if (success) {
            self.setupRightBarButtonItem()
            self.updateTheme()
        } else {
            // handle cancel operation from user
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupRightBarButtonItem()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        // You need to call `- updateTheme` here in case the sign-in happens before `- viewWillAppear:` is called.
        updateTheme()
        willEnterForegroundObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.current) { _ in
            self.updateTheme()
        }

            presentSignInViewController()
        
        var demoFeature = DemoFeature.init(
            name: NSLocalizedString("User Sign-in",
                comment: "Label for demo menu option."),
            detail: NSLocalizedString("Enable user login with popular 3rd party providers.",
                comment: "Description for demo menu option."),
            icon: "UserIdentityIcon", storyboard: "UserIdentity")
        
        demoFeatures.append(demoFeature)
        
        demoFeature = DemoFeature.init(
            name: NSLocalizedString("User Data Storage",
                comment: "Label for demo menu option."),
            detail: NSLocalizedString("Save user files in the cloud and sync user data in key/value pairs.",
            comment: "Description for demo menu option."),
            icon: "UserFilesIcon", storyboard: "UserDataStorage")
        
        demoFeatures.append(demoFeature)
        
        demoFeature = DemoFeature.init(
            name: NSLocalizedString("NoSQL",
                comment: "Label for demo menu option."),
            detail: NSLocalizedString("Store data in the cloud.",
                comment: "Description for demo menu option."),
            icon: "NoSQLIcon", storyboard: "NoSQLDatabase")
        
        demoFeatures.append(demoFeature)
        
        // added by me
        demoFeature = DemoFeature.init(
            name: NSLocalizedString("Swiper",
                                    comment: "To Swiper MVC."),
            detail: NSLocalizedString("Store data in the cloud.",
                                      comment: "Description for demo menu option."),
            icon: "NoSQLIcon", storyboard: "Swiper")
        demoFeatures.append(demoFeature)
        
        demoFeature = DemoFeature.init(
            name: NSLocalizedString("AddProduct",
                                    comment: "To AddProduct MVC."),
            detail: NSLocalizedString("Store data in the cloud.",
                                      comment: "Description for demo menu option."),
            icon: "NoSQLIcon", storyboard: "AddProduct")
        demoFeatures.append(demoFeature)

    }

    
    deinit {
        NotificationCenter.default.removeObserver(willEnterForegroundObserver)
    }

    func setupRightBarButtonItem() {
            navigationItem.rightBarButtonItem = loginButton
            navigationItem.rightBarButtonItem!.target = self
            
            if (AWSSignInManager.sharedInstance().isLoggedIn) {
                navigationItem.rightBarButtonItem!.title = NSLocalizedString("Sign-Out", comment: "Label for the logout button.")
                navigationItem.rightBarButtonItem!.action = #selector(MainViewController.handleLogout)
            }
    }
    
    func presentSignInViewController() {
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            let loginStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
            let loginController: SignInViewController = loginStoryboard.instantiateViewController(withIdentifier: "SignIn") as! SignInViewController
            loginController.canCancel = false
            loginController.didCompleteSignIn = onSignIn
            let navController = UINavigationController(rootViewController: loginController)
            navigationController?.present(navController, animated: true, completion: nil)
        }
    }
    
    // MARK: - UITableViewController delegates
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainViewCell")!
        let demoFeature = demoFeatures[indexPath.row]
        cell.imageView!.image = UIImage(named: demoFeature.icon)
        cell.textLabel!.text = demoFeature.displayName
        cell.detailTextLabel!.text = demoFeature.detailText
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoFeatures.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let demoFeature = demoFeatures[indexPath.row]
        let storyboard = UIStoryboard(name: demoFeature.storyboard, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: demoFeature.storyboard)
        self.navigationController!.pushViewController(viewController, animated: true)
    }

    func updateTheme() {
        let settings = ColorThemeSettings.sharedInstance
        settings.loadSettings { (themeSettings: ColorThemeSettings?, error: Error?) -> Void in
            guard let themeSettings = themeSettings else {
                 print("Failed to load color: \(error)")
                return
            }
            DispatchQueue.main.async(execute: {
                let titleTextColor: UIColor = themeSettings.theme.titleTextColor.UIColorFromARGB()
                self.navigationController!.navigationBar.barTintColor = themeSettings.theme.titleBarColor.UIColorFromARGB()
                self.view.backgroundColor = themeSettings.theme.backgroundColor.UIColorFromARGB()
                self.navigationController!.navigationBar.tintColor = titleTextColor
                self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: titleTextColor]
            })
        }
    }
    
    
    func handleLogout() {
        if (AWSSignInManager.sharedInstance().isLoggedIn) {
            ColorThemeSettings.sharedInstance.wipe()
            AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?, authState: AWSIdentityManagerAuthState, error: Error?) in
                self.navigationController!.popToRootViewController(animated: false)
                self.setupRightBarButtonItem()
                self.updateTheme()
                    self.presentSignInViewController()
            })
            // print("Logout Successful: \(signInProvider.getDisplayName)");
        } else {
            assert(false)
        }
    }
}

class FeatureDescriptionViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "Back", style: .plain, target: nil, action: nil)
    }
}
