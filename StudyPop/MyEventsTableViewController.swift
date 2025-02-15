//
//  MyEventsTableViewController.swift
//  StudyPop
//
//  Created by Nicholas Park on 7/2/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import UIKit
import CoreData

@objc protocol MyEventsProtocol{
    func backClicked()
    func refreshClicked()
}

class MyEventsTableViewController: UITableViewController {

    struct Constants{
        static let RefreshTitle = "Refresh"
        static let RefreshingTitle = "Loading..."
        static let CellReuseIdentifier = "EventCell"
        static let EventViewSegue = "EventView Segue"
    }
    
    var members = [EventMember]()
    var canLoadMore = true
    var loading = false
    var refreshButton:UIBarButtonItem?
    var user:User?
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "My Events"
        
        refreshButton = UIBarButtonItem(title: Constants.RefreshTitle, style: .Plain, target: self, action: #selector(MyEventsProtocol.refreshClicked))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(MyEventsProtocol.backClicked))
        navigationItem.rightBarButtonItem = refreshButton
        
        getLocalEvents()
        if members.count < 1 {
            indexMyEvents()
        }
    }

    func backClicked(){
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if members.count < 1 {
            return "You haven't signed up for any events"
        }
        return nil
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return members.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellReuseIdentifier, forIndexPath: indexPath) as! EventTableViewCell
        if members[indexPath.row].fromEvent != nil{
            let event = members[indexPath.row].fromEvent
            cell.titleLabel.text = event!.name!
            if event!.start != nil{
                let formatter = NSDateFormatter()
                formatter.dateFormat = "EEEE"
                cell.dayLabel.text = "\(formatter.stringFromDate(event!.start!))"
                formatter.dateFormat = "MMM dd"
                cell.dateLabel.text = "\(formatter.stringFromDate(event!.start!))"
                if event!.startString != nil{
                    formatter.dateFormat = "H:mm a"
                    cell.hourLabel.text = "\(formatter.stringFromDate(event!.start!))"
                }
            }
            if event!.info != nil{
                cell.textView.text = event!.info!
            }
            if event!.currentpeople != nil{
                cell.attendingLabel.text = "\(event!.currentpeople!.intValue)"
            }
            
            //cell.event = event
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if members[indexPath.row].fromEvent != nil{
            performSegueWithIdentifier(Constants.EventViewSegue, sender: members[indexPath.row].fromEvent!.safekey)
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */


    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            dropEvent(members[indexPath.row].safekey!)
            performOnMain(){
                self.sharedContext.deleteObject(self.members[indexPath.row])
            }
            members.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    func dropEvent(safekey:String){
        let params = [StudyPopClient.ParameterKeys.Controller: StudyPopClient.ParameterValues.EventMembersController,
                      StudyPopClient.ParameterKeys.Method: StudyPopClient.ParameterValues.DeleteMethod,
                      StudyPopClient.ParameterKeys.ApiKey: StudyPopClient.Constants.ApiKey,
                      StudyPopClient.ParameterKeys.ApiSecret: StudyPopClient.Constants.ApiSecret,
                      StudyPopClient.ParameterKeys.SafeKey: safekey,
                      StudyPopClient.ParameterKeys.Token : self.user!.token!
        ]
        StudyPopClient.sharedInstance.httpGet("", parameters: params){ (results,error) in
            func sendError(error: String){
                self.simpleError(error)
            }
            
            guard error == nil else{
                sendError(error!.localizedDescription)
                return
            }
            
            guard let stat = results[StudyPopClient.JSONReponseKeys.Result] as? String where stat == StudyPopClient.JSONResponseValues.Success else{
                sendError("StudyPop Api Returned error: \(results[StudyPopClient.JSONReponseKeys.Error]!)")
                return
            }
            
        }
    }

    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.EventViewSegue{
            let safekey = sender as! String
            if let evc = segue.destinationViewController as? EventViewController{
                evc.user = user!
                evc.safekey = safekey
                print("OK, so the safekey is !!! \(safekey)")
            }
        }
    }
    
    
    func refreshClicked(){
        canLoadMore = true
        members = [EventMember]()
        updateUI()
        indexMyEvents()
    }
    
    func findEventMember(safekey: String) -> EventMember?{
        let request = NSFetchRequest(entityName: "EventMember")
        request.predicate = NSPredicate(format: "safekey == %@", safekey)
        do{
            let results = try sharedContext.executeFetchRequest(request)
            if results.count > 0{
                if let temp = results[0] as? EventMember{
                    return temp
                }
            }
        } catch {
            let fetchError = error as NSError
            print("The error was \(fetchError)")
        }
        return nil
    }
    
    func findEvent(safekey: String) -> Event?{
        let request = NSFetchRequest(entityName: "Event")
        request.predicate = NSPredicate(format: "safekey == %@", safekey)
        do{
            let results = try sharedContext.executeFetchRequest(request)
            if results.count > 0{
                if let temp = results[0] as? Event{
                    return temp
                }
            }
        } catch {
            let fetchError = error as NSError
            print("The error was \(fetchError)")
        }
        return nil
    }
    
    
    
    // MARK: -IndexMyEvents
    func indexMyEvents(){
        if !loading && canLoadMore{
            refreshButton!.title = Constants.RefreshingTitle
            refreshButton!.enabled = false
            loading = true
            let params = [StudyPopClient.ParameterKeys.Controller: StudyPopClient.ParameterValues.EventMembersController,
                          StudyPopClient.ParameterKeys.Method: StudyPopClient.ParameterValues.MyIndexMethod,
                          StudyPopClient.ParameterKeys.ApiKey: StudyPopClient.Constants.ApiKey,
                          StudyPopClient.ParameterKeys.ApiSecret: StudyPopClient.Constants.ApiSecret,
                          StudyPopClient.ParameterKeys.Offset: "\(members.count)",
                          StudyPopClient.ParameterKeys.Token : user!.token!
            ]
            StudyPopClient.sharedInstance.httpGet("", parameters: params) { (results,error) in
                
                self.loading = false
                func sendError(error: String){
                    self.refreshButton!.title = Constants.RefreshTitle
                    self.refreshButton!.enabled = true
                    self.simpleError(error)
                }
                
                guard error == nil else{
                    sendError(error!.localizedDescription)
                    return
                }
                
                guard let stat = results[StudyPopClient.JSONReponseKeys.Result] as? String else{
                    sendError("StudyPopApi: Could not get proper response from server")
                    return
                }
                
                if stat == StudyPopClient.JSONResponseValues.Success{
                    if let membersDictionary = results![StudyPopClient.JSONReponseKeys.EventMembers] as? [[String:AnyObject]]{
                        for i in membersDictionary{
                            let dict = i as Dictionary<String,AnyObject>
                            let safekey = dict[EventMember.Keys.SafeKey] as! String
                            var member:EventMember?
                            member = self.findEventMember(safekey)
                            if member == nil{
                                member = EventMember.init(dictionary:dict, context: self.sharedContext)
                            }
                            if let eventDict = dict[EventMember.Keys.Event] as? [String:AnyObject]{
                                let safekey = dict[EventMember.Keys.SafeKey] as! String
                                if let tempEvent = self.findEvent(safekey){
                                    print("Found an old event")
                                    member!.fromEvent = tempEvent
                                }else{
                                    print("Found a new event")
                                    let fromEvent = Event.init(dictionary: eventDict, context: self.sharedContext)
                                    member!.fromEvent = fromEvent
                                }
                                
                            }
                            self.members.append(member!)
                            
                        }
                        performOnMain(){
                            CoreDataStackManager.sharedInstance().saveContext()
                        }
                        if membersDictionary.count < 10{
                            self.canLoadMore = false
                        }else{
                            self.canLoadMore = true
                        }
                        self.updateUI()
                    }
                }else if let responseError = results[StudyPopClient.JSONReponseKeys.Error] as? String{
                    sendError(responseError)
                }
            }
        }
    }
    
    // MARK: - Method to Get Local Events
    func getLocalEvents(){
        let fetchRequest = NSFetchRequest(entityName: "EventMember")
        fetchRequest.includesSubentities = true
        do{
            self.members = try sharedContext.executeFetchRequest(fetchRequest) as! [EventMember]
            for i in self.members{
                let member = i as? EventMember
                print("The event was \(member?.fromEvent?.name) and the key was \(member?.fromEvent?.safekey)")
            }
            updateUI()
        } catch let error as NSError{
            print("The error was \(error)")
        }
    }

    func updateUI(){
        performOnMain(){
            self.loading = false
            self.refreshButton!.title = Constants.RefreshTitle
            self.tableView.reloadData()
        }
    }

}
