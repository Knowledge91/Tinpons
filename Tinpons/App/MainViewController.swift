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
import AWSDynamoDB
import SwiftIconFont

class MainViewController: SwiperViewController {
   
    // MARK: - View lifecycle
    func onSignIn (_ success: Bool) {
        // handle successful sign in
        if (success) {
            createUserAccountIfNotExisting()
            self.setupLeftBarButtonItem()
            syncCoreDataWithDynamoDB()
            resetUI()
        } else {
            // handle cancel operation from user
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupLeftBarButtonItem()
        presentSignInViewController()
    }

    func setupLeftBarButtonItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Profile", style: .done, target: self, action: #selector(profileButtonTapped))
            navigationItem.leftBarButtonItem?.icon(from: .Ionicon, code: "person", ofSize: 20)
    }
    func profileButtonTapped() {
        performSegue(withIdentifier: "presentProfile", sender: nil)
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
    
    func handleLogout() {
        if (AWSSignInManager.sharedInstance().isLoggedIn) {
            AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?, authState: AWSIdentityManagerAuthState, error: Error?) in
                self.navigationController!.popToRootViewController(animated: false)
                self.setupLeftBarButtonItem()
                    self.presentSignInViewController()
            })
            // print("Logout Successful: \(signInProvider.getDisplayName)");
        } else {
            assert(false)
        }
    }


    
    func createUserAccountIfNotExisting() {
        //check if User Account exists
        let dynamoDBOBjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDBOBjectMapper.load(User.self, hashKey: userId!, rangeKey: nil).continueWith(block: { [weak self] (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error {
                print("The request failed. Error: \(error)")
            } else if let _ = task.result as? User {
                //print("found something")
            } else if task.result == nil {
                // User does not exist => create
                let user = User()
                user?.userId = self?.userId
                user?.createdAt = Date().iso8601.dateFromISO8601?.iso8601 // "2017-03-22T13:22:13.933Z"
                user?.tinponCategories = ["👕", "👖", "👞"]
                user?.role = "User"
                dynamoDBOBjectMapper.save(user!).continueWith(block: { (task:AWSTask<AnyObject>!) -> Void in
                    if let error = task.error {
                        print("The request failed. Error: \(error)")
                    } else {
                        print("User created")
                        // Do something with task.result or perform other operations.
                    }
                })
            }
            return nil
        })
    }
    
    func syncCoreDataWithDynamoDB() {
        SwipedTinponsCore.resetAllRecords()
        let tests = SwipedTinponsCore.fetchData()
        //print("test \(tests!.count)")


        SwipedTinpon().loadAllSwipedTinponsFor(userId: userId!, onComplete: { swipedTinpons in
            print("load tinponswiped")
            print(swipedTinpons.count)
            for swipedTinpon in swipedTinpons {
                SwipedTinponsCore.save(swipedTinpon: swipedTinpon)
            }
        })
    }
    
    
    // MARK: Unwind Profile
    @IBAction func unwindProfileViewController(segue: UIStoryboardSegue) {
        handleLogout()
    }
}
