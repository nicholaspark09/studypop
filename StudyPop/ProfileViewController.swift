//
//  ProfileViewController.swift
//  StudyPop
//
//  Created by Nicholas Park on 6/6/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController {

    
    struct Constants{
        static let Controller = "ProfileView"
        static let EditProfileSegue = "ProfileEdit Segue"
    }
    
    @IBOutlet var editButton: UIButton!
    @IBOutlet var subjectLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var infoTextView: UITextView!
    @IBOutlet var loadingView: UIActivityIndicatorView!
    @IBOutlet var profileImageView: UIImageView!
    
    
    var user: User?
    var profile:Profile?
    var profileUser = ""
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if user != nil && profileUser == "" && profile == nil && profileUser != user!.token!{
            print("You should be grabbing it")
            //This is your profile
            editButton.hidden = false
            getMyProfile()
        }else{
            //This is someone else's profile
            if profile != nil{
                self.updateUI()
            }else if profileUser != ""{
                loadingView.startAnimating()
                let params = [StudyPopClient.ParameterKeys.Controller: StudyPopClient.ParameterValues.ProfilesController,
                              StudyPopClient.ParameterKeys.Method: StudyPopClient.ParameterValues.UserViewMethod,
                              StudyPopClient.ParameterKeys.ApiKey: StudyPopClient.Constants.ApiKey,
                              StudyPopClient.ParameterKeys.ApiSecret: StudyPopClient.Constants.ApiSecret,
                              StudyPopClient.ParameterKeys.Token : user!.token!,
                              StudyPopClient.ParameterKeys.SafeKey : profileUser
                ]
                StudyPopClient.sharedInstance.httpGet("", parameters: params){ (results,error) in
                    func sendError(error: String){
                        self.simpleError(error)
                        self.loadingView.stopAnimating()
                    }
                    
                    guard error == nil else{
                        sendError(error!.localizedDescription)
                        return
                    }
                    
                    guard let stat = results[StudyPopClient.JSONReponseKeys.Result] as? String where stat == StudyPopClient.JSONResponseValues.Success else{
                        sendError("StudyPop Api Returned error: \(results[StudyPopClient.JSONReponseKeys.Error])")
                        return
                    }
                    performOnMain(){
                        self.loadingView.stopAnimating()
                    }
                    if let profileDict = results[StudyPopClient.JSONReponseKeys.Profile] as? [String:AnyObject]{
                        
                        self.profile = Profile.init(dictionary: profileDict, context: self.sharedContext)
                        if let safekey = results[StudyPopClient.JSONReponseKeys.SafeKey] as? String{
                            self.profile!.safekey = safekey
                            print("YOu found a safekey with \(safekey) as the value")
                        }
                        self.profile!.user = self.profileUser
                        self.updateUI()
                    }else{
                        print("You ended up here...")
                    }
                }
            }
        }
    }

    
    @IBAction func backClicked(sender: UIButton) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: MyProfileViewMethod
    func getMyProfile(){
        self.loadingView.startAnimating()
        let params = [StudyPopClient.ParameterKeys.Controller: StudyPopClient.ParameterValues.ProfilesController,
                      StudyPopClient.ParameterKeys.Method: StudyPopClient.ParameterValues.MyProfileMethod,
                      StudyPopClient.ParameterKeys.ApiKey: StudyPopClient.Constants.ApiKey,
                      StudyPopClient.ParameterKeys.ApiSecret: StudyPopClient.Constants.ApiSecret,
                      StudyPopClient.ParameterKeys.Token : user!.token!
        ]
        StudyPopClient.sharedInstance.httpGet("", parameters: params){ (results,error) in
            func sendError(error: String){
                self.simpleError(error)
                self.loadingView.stopAnimating()
            }
            
            guard error == nil else{
                sendError(error!.localizedDescription)
                return
            }
            
            guard let stat = results[StudyPopClient.JSONReponseKeys.Result] as? String where stat == StudyPopClient.JSONResponseValues.Success else{
                sendError("StudyPop Api Returned error: \(results[StudyPopClient.JSONReponseKeys.Error])")
                return
            }
            performOnMain(){
                self.loadingView.stopAnimating()
            }
            if let profileDict = results[StudyPopClient.JSONReponseKeys.Profile] as? [String:AnyObject]{
                
                self.profile = Profile.init(dictionary: profileDict, context: self.sharedContext)
                if let safekey = results[StudyPopClient.JSONReponseKeys.SafeKey] as? String{
                    self.profile!.safekey = safekey
                    print("YOu found a safekey with \(safekey) as the value")
                }
                self.profile!.user = self.user!.token!
                self.updateUI()
            }else{
                print("You ended up here...")
            }
        }
    }
    
    
    
    func updateUI(){
        performOnMain(){
            self.nameLabel.text = self.profile!.name!
            self.infoTextView.text = self.profile!.info!
            //Check the DB for a profile Pic
            print("In the midst of the project")
            if self.profile!.hasPhoto != nil{
                print("Step 1")
                self.profileImageView.image = UIImage(data: self.profile!.hasPhoto!.blob!)
                self.profileImageView.contentMode = UIViewContentMode.ScaleAspectFit
            }else if self.profile!.image != nil && self.profile!.image! != ""{
                print("Step 2")
                var found = false
                if let oldProfile = self.findProfileInDB(){
                    if oldProfile.image != nil && oldProfile.image! == self.profile!.image! {
                        print("Step 3")
                        if oldProfile.hasPhoto != nil{
                            self.profileImageView.image = UIImage(data: oldProfile.hasPhoto!.blob!)
                            self.profileImageView.contentMode = UIViewContentMode.ScaleAspectFit
                            found = true
                        }
                    }
                }
                if !found {
                    //Look up the image from the DB
                    //Find the image
                    StudyPopClient.sharedInstance.findProfileImage(self.user!.token!, safekey: self.profile!.safekey!){ (imageData,error) in
                        func sendError(error: String){
                            print("The error was: \(error)")
                            //Do not interrupt the user for this image GET
                            //If this doesn't update, it's not super important
                        }
                        
                        guard error == nil else{
                            sendError(error!)
                            return
                        }
                        
                        guard let imageData = imageData else{
                            sendError("No image")
                            return
                        }
                        
                        performOnMain(){
                            let image = UIImage(data: imageData)
                            self.profileImageView.image = image
                            self.profileImageView.contentMode = UIViewContentMode.ScaleAspectFit
                            let photoDict = [Photo.Keys.Blob : imageData, Photo.Keys.Controller : "profiles", Photo.Keys.TheType : "\(1)", Photo.Keys.SafeKey :"", Photo.Keys.ParentKey : self.profile!.safekey!]
                            let photo = Photo.init(dictionary: photoDict, context: self.sharedContext)
                            self.profile!.hasPhoto = photo
                            CoreDataStackManager.sharedInstance().saveContext()
                        }
                    }
                }
            }
        
            
            if self.profile!.city != nil{
                
                    self.cityLabel.text = self.profile!.city!.name!
    
            }else{
                self.cityLabel.text = "No City"
            }
            if self.profile!.subject != nil{
                
                    self.subjectLabel.text = self.profile!.subject!.name!
            }else{
                self.subjectLabel.text = "No Subject"
            }
        }
    }
    
    // MARK: FindProfile from Local DB
    func findProfileInDB() -> Profile?{
        let request = NSFetchRequest(entityName: "Profile")
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "user == %@", user!.token!)
        do{
            let results = try sharedContext.executeFetchRequest(request)
            if results.count > 0{
                if let temp = results[0] as? Profile{
                    return temp
                }
            }
        } catch {
            let fetchError = error as NSError
            print("The error was \(fetchError)")
        }
        return nil
    }

    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.EditProfileSegue{
            if let epc = segue.destinationViewController.contentViewController as? EditProfileViewController{
                epc.user = user!
                epc.profile = profile!
                epc.city = self.profile!.city
                epc.subject = self.profile!.subject
            }
        }
    }


}
