//
//  ViewController.swift
//  WorldCup
//
//  Created by Pietro Rea on 8/2/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate {
  
  var coreDataStack: CoreDataStack!
    var frc:NSFetchedResultsController!
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        switch motion{
        case .MotionShake:
            self.addButton.enabled = true
        default:
            break
        }
    }
    
    func addTeam(sender:AnyObject){
        let alert = UIAlertController(title: "新增国家队", message: "请输入一个球队", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField:UITextField!) -> Void in
            textField.placeholder = "所在赛区"
        }
        alert.addTextFieldWithConfigurationHandler { (textField:UITextField!) -> Void in
            textField.placeholder = "国家队名"
        }
        alert.addAction(UIAlertAction(title: "保存", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
            let zonetf = alert.textFields![0] as! UITextField
            let teamtf = alert.textFields![1] as! UITextField
            
            let team = NSEntityDescription.insertNewObjectForEntityForName("Team", inManagedObjectContext: self.coreDataStack.context) as! Team
            team.qualifyingZone = zonetf.text
            team.teamName = teamtf.text
            team.imageName = "china-flag"
            
            self.coreDataStack.saveContext()
        }))
        
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction!) -> Void in
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    tableView.delegate = self
    tableView.dataSource = self
    
    let fr = NSFetchRequest(entityName: "Team")
    let zoneSd = NSSortDescriptor(key: "qualifyingZone", ascending: true)
    let scoreSd = NSSortDescriptor(key: "wins", ascending: false)
    let nameSd = NSSortDescriptor(key: "teamName", ascending: true)
    
    fr.sortDescriptors = [zoneSd,scoreSd,nameSd]
    
    frc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: coreDataStack.context, sectionNameKeyPath: "qualifyingZone", cacheName: "worldCupCache")
    frc.delegate = self
    
    var error:NSError?
    if !frc.performFetch(&error){
        println("\(error?.localizedDescription)")
    }
    
  }
  
  func numberOfSectionsInTableView
    (tableView: UITableView) -> Int {
      
      return frc.sections!.count
  }
  
  func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = frc.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
  }

  func tableView(tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath)
    -> UITableViewCell {
      
      let resuseIdentifier = "teamCellReuseIdentifier"
      
      var cell =
      tableView.dequeueReusableCellWithIdentifier(
        resuseIdentifier, forIndexPath: indexPath)
        as! TeamCell
      
      configureCell(cell, indexPath: indexPath)
      
      return cell
  }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = frc.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.name
    }
    
  func configureCell(cell: TeamCell, indexPath: NSIndexPath) {
    let team = frc.objectAtIndexPath(indexPath) as! Team
    cell.flagImageView.image = UIImage(named: team.imageName)
    cell.teamLabel.text = team.teamName
    cell.scoreLabel.text = "Wins: \(team.wins)"
  }
  
  func tableView(tableView: UITableView,
    didSelectRowAtIndexPath indexPath: NSIndexPath) {
      let team = frc.objectAtIndexPath(indexPath) as! Team
        var cell =
        tableView.dequeueReusableCellWithIdentifier(
            "teamCellReuseIdentifier", forIndexPath: indexPath)
            as! TeamCell
        team.wins = NSNumber(integer: (team.wins.integerValue + 1))
        configureCell(cell, indexPath: indexPath)
        coreDataStack.saveContext()
  }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type{
        case .Update:
            let cell  = tableView.cellForRowAtIndexPath(indexPath!) as! TeamCell
            configureCell(cell, indexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        default:
            break
            
        }
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type{
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
        default:
            break
        }
    }
}

