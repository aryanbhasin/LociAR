//
//  ViewController.swift
//  LociAR
//
//  Created by Aryan on 10/11/18.
//  Copyright © 2018 Aryan. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
//import FileBrowser

class ViewController: UIViewController, ARSCNViewDelegate {
    var fileStringArray = [String]()
//    let tap = UITapGestureRecognizer(target: self, action: Selector("tapFunction:"))
//    var fileManager = FileManager()
    
    
    var currentNodeOnTap:SCNNode?
    
    var currentTextNodeOnTap: SCNNode?
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var TapStack: UIStackView!
    @IBOutlet weak var ButtonStack: UIStackView!
    
    @IBOutlet weak var startPathButton: UIButton!
    @IBOutlet weak var savePathButton: UIButton!
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!

//    @IBAction func editNodeButton(_ sender: UIButton) {
//        editNode(node: self.currentNodeOnTap!)
//    }
//    @IBAction func deleteNodeButton(_ sender: UIButton) {
//        deleteNode(node: self.currentNodeOnTap!)
//    }
    
   
    
    @IBAction func deleteNodeBUtton(_ sender: UIButton) {
        deleteNode(node: (self.currentNodeOnTap?.parent!)!)
        
    }
    
    
    @IBAction func doneButton(_ sender: UIButton) {
        
        TapStack.isHidden = true;
        ButtonStack.isHidden = true;
    }
    
    //
    
    // BUGS TO SQUASH:
    // When text is updated it also needs to be changed for the physical text node
    // Hide the stack again after a done button
    
    
//    @IBOutlet weak var editNoteButton: UIButton!
//    @IBOutlet weak var deleteNodeButton: UIButton!
    
    @IBOutlet weak var nodeNameText: UILabel!
    @IBOutlet weak var nodeDescriptionText: UILabel!
    
    
    let configuration = ARWorldTrackingConfiguration()
    
    @IBAction func loadB(_ sender: UIButton) {
        loadSave()
    }
    
    @IBAction func saveB(_ sender: UIButton) {
        saveForm()
    }
    
    
    @IBAction func startB(_ sender: UIButton) {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        sceneView.session.pause()
        sceneView.session.run(configuration, options: [.resetTracking])
    }
    
//    @IBAction func savePathButton(_ sender: UIButton) {
//        saveForm()
//    }
//    @IBAction func startPathButton(_ sender: UIButton) {
//        // starts new path
//
//        // resets tracking-- (0,0,0) initialized at user's current location
//        sceneView.session.pause()
//        sceneView.session.run(configuration, options: [.resetTracking])
//    }
//
//    @IBAction func loadPathButton(_ sender: UIButton) {
//        loadSave()
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        TapStack.isHidden = true
        ButtonStack.isHidden = true
        
        let loadButtonImage = UIImage(named: "")
        
        let doubleTapGesture = UITapGestureRecognizer (target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        sceneView.addGestureRecognizer(doubleTapGesture)
        
        let normalTapGesture = UITapGestureRecognizer (target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(normalTapGesture)
    
    }
    
    @objc func handleDoubleTap(sender: UITapGestureRecognizer) {
        // area tapped
        guard let areaTapped = sender.view as? ARSCNView else {
            return
        }
        let touch = sender.location(in: areaTapped)
        // this is ARKit hitTesting which performs hit test on real world
        let hitTestResults = areaTapped.hitTest(touch, types: [.featurePoint, .estimatedHorizontalPlane])
        if hitTestResults.isEmpty == false {
            if let hitTestResult = hitTestResults.first {
               
                let virtualAnchor = ARAnchor(transform: hitTestResult.worldTransform)
                self.sceneView.session.add(anchor: virtualAnchor)
            }
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let areaTapped = sender.view as? ARSCNView else {
            return
        }
        let touch = sender.location(in: areaTapped)
        // This is SceneKit hitTesting which performs hit test on SceneKit objects
        let hitTestResults = areaTapped.hitTest(touch)
        if hitTestResults.isEmpty {
            // no virtual objects where user taps
            // ignore
        } else {
            let results = hitTestResults.first!
            self.currentNodeOnTap = results.node
//            var textName = self.currentNodeOnTap!.name! + "text"
//            - (SCNNode *)childNodeWithName:(NSString *)textName recursively:(YES)recursively;
            let name = results.node.name
            if (name != nil) {
                let text = name!.components(separatedBy: "@")
                let nameOfNode: String = text[0]
                let description: String = text[1]
                print(nameOfNode)
                
                nodeNameText.text = nameOfNode
                nodeDescriptionText.text = description
                TapStack.isHidden = false
                ButtonStack.isHidden = false
            }
            

        }
    }
    

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
            print("flag 4")
            if anchor is ARPlaneAnchor {
                return
            }
            let newNode = SCNNode(geometry: SCNCylinder(radius: 0.02, height: 0.04))
            print("flag 5")
            //Setting title and message for the alert dialog
            let alertController = UIAlertController(title: "Enter the following details", message: "", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Create", style: .default) { (_) in
                //getting the input values from user
                newNode.name = alertController.textFields?[0].text
                newNode.name = newNode.name! + "@" + (alertController.textFields?[1].text)!
                //            print("I am here")
                
                print(newNode.name)
                let text = newNode.name?.components(separatedBy: "@")
                let nameOfNode: String = text![0]
                let description: String = text![1]
                //            print(node.childNodes)
                
                let displayNodeName = SCNText(string: nameOfNode, extrusionDepth: 1)
                let material = SCNMaterial()
                material.diffuse.contents = UIColor.white
                displayNodeName.materials = [material]
                
                let textNode = SCNNode()
                textNode.position = SCNVector3(newNode.position.x, newNode.position.y, newNode.position.z + 0.07)
                textNode.scale = SCNVector3(0.004, 0.004, 0.004)
                textNode.geometry = displayNodeName
                textNode.name = nameOfNode + "text"
                //            node.replaceChildNode(<#T##oldChild: SCNNode##SCNNode#>, with: <#T##SCNNode#>)
                node.addChildNode(textNode)
            }
            
            //the cancel action doing nothing
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                
                self.removeNode(newNode: newNode)
                
            }
            
            //adding textfields to our dialog box
            alertController.addTextField { (textField) in
                textField.placeholder = "Enter Name"
            }
            //adding textfields to our dialog box
            alertController.addTextField { (textField) in
                textField.placeholder = "Enter Description"
            }
            
            //adding the action to dialogbox
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            //finally presenting the dialog box
            self.present(alertController, animated: true, completion: nil)
            
            newNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            
            node.addChildNode(newNode)
    }
    
    func removeNode(newNode: SCNNode) {
        newNode.removeFromParentNode()
        
//        self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
//            if node.name == newNode.name {
//            node.removeFromParentNode()
//            }
//        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
//    func createNode(node: SCNNode, anchor: ARAnchor) {
//        let newNode = SCNNode()
//        newNode.geometry = SCNSphere(radius: 0.05)
//        newNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
//        newNode.name = "sphere"
//        sceneView.scene.rootNode.addChildNode(newNode)
//        print("Node created")
//    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func loadSave() {
//        let fileBrowser = FileBrowser()
//        self.presentViewController(fileBrowser, animated: true, completion: nil)
        
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Enter name of the map?", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Load", style: .default) { (_) in
            //getting the input values from user
            let name = alertController.textFields?[0].text
            print("flag 1")
            self.loadMap(name: name!)
            print("flag 2")
        }
       
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Name"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    
        
        //listFilesFromDocumentsFolder()
    }
    
    func loadMap(name: String) {
        let storedData = UserDefaults.standard
        if let data = storedData.data(forKey: name) {
            if let unarchived = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [ARWorldMap.classForKeyedUnarchiver()], from: data), let worldMap = unarchived as? ARWorldMap {
                let configuration = ARWorldTrackingConfiguration(); configuration.initialWorldMap = worldMap; configuration.planeDetection = .horizontal;
//                self.lblMessage.text = "Previous world map loaded";
                sceneView.session.run(configuration)
                print("flag 3")
            }
        } else {
            let configuration = ARWorldTrackingConfiguration(); configuration.planeDetection = .horizontal; sceneView.session.run(configuration)
        }
    }
    
    func saveForm() {
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Enter name of the map?", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            //getting the input values from user
            let name = alertController.textFields?[0].text
            self.saveMap(name: name!)
            
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Name"
        }
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        print("flag 6")
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
        print("flag 7")
        
    }
    func saveMap(name: String) {
        self.sceneView.session.getCurrentWorldMap {
        //SHow a form
        worldMap, error in
        if error != nil { print(error?.localizedDescription ?? "Unknown error")
            return
        }
        if let map = worldMap {
                let data = try! NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                // save in user defaults
                let savedMap = UserDefaults.standard;
                savedMap.set(data, forKey: name);
                savedMap.synchronize()
            }
        }
    }
    
//    func editNode(node: SCNNode) {
//        let alertController = UIAlertController(title: "Enter new name", message: "", preferredStyle: .alert)
//        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
//            //getting the input values from user
//            let newName = alertController.textFields?[0].text
//            let currentName = node.name!.components(separatedBy: "@")
//            var nameOfNode: String = currentName[0]
//            let description: String = currentName[1]
//            nameOfNode = newName ?? currentName[0]
//
//            node.name = nameOfNode + "@" + description
//
//            let displayNodeName = SCNText(string: nameOfNode, extrusionDepth: 1)
//            let material = SCNMaterial()
//            material.diffuse.contents = UIColor.white
//            displayNodeName.materials = [material]
//
//            let newTextNode = SCNNode()
//            newTextNode.position = SCNVector3(node.position.x, node.position.y, node.position.z + 0.07)
//            newTextNode.scale = SCNVector3(0.004, 0.004, 0.004)
//            newTextNode.geometry = displayNodeName
//            newTextNode.name = "shape"
//
//            node.addChildNode(newTextNode)
//
//        }
//
//        //the cancel action doing nothing
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
//
//        //adding textfields to our dialog box
//        alertController.addTextField { (textField) in
//            textField.placeholder = "Enter New Name"
//        }
//        //adding the action to dialogbox
//        alertController.addAction(confirmAction)
//        alertController.addAction(cancelAction)
//
//        //finally presenting the dialog box
//        self.present(alertController, animated: true, completion: nil)
//
//
//    }
    
    func deleteNode(node:SCNNode) {
       node.removeFromParentNode()
        ButtonStack.isHidden = true
        TapStack.isHidden = true
    }
    
    


    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
}
