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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    @IBAction func loadPathButton(_ sender: UIButton) {
        // loads existing path-- use persistence
    }
    
    @IBAction func startPathButton(_ sender: UIButton) {
        // starts new path
        
        // resets tracking-- (0,0,0) initialized at user's current location
        sceneView.session.pause()
        sceneView.session.run(configuration, options: [.resetTracking])
    }
    
    @IBAction func savePathButton(_ sender: UIButton) {
        // saves path-- use persistence
    }
    
    @IBAction func loadButton(_ sender: Any) {
        loadSave()
    }

    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // shows origin and feature points for debugging
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        let longPressGesture = UILongPressGestureRecognizer (target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 1.5
        sceneView.addGestureRecognizer(longPressGesture)
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        // area tapped
        print("This works")
        guard let areaTapped = sender.view as? ARSCNView else {
            return
        }
        let touch = sender.location(in: areaTapped)
        let hitTestResults = areaTapped.hitTest(touch, types: [.featurePoint, .estimatedHorizontalPlane])
        if hitTestResults.isEmpty == false {
            if let hitTestResult = hitTestResults.first {
                let virtualAnchor = ARAnchor(transform: hitTestResult.worldTransform)
                self.sceneView.session.add(anchor: virtualAnchor)
                print("This also works")
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            return
        }
        let newNode = SCNNode(geometry: SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0))
        newNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        node.addChildNode(newNode)
        //createNode(node: node, anchor: anchor)
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
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Enter name of the map?", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            //getting the input values from user
            let name = alertController.textFields?[0].text
            self.loadMap(name: name!)
            
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
    
        
//        listFilesFromDocumentsFolder()
    }
    
    func loadMap(name: String) {
        let storedData = UserDefaults.standard
        if let data = storedData.data(forKey: name) {
            if let unarchived = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [ARWorldMap.classForKeyedUnarchiver()], from: data), let worldMap = unarchived as? ARWorldMap {
                let configuration = ARWorldTrackingConfiguration(); configuration.initialWorldMap = worldMap; configuration.planeDetection = .horizontal;
//                self.lblMessage.text = "Previous world map loaded";
                sceneView.session.run(configuration)
            }
        } else {
            let configuration = ARWorldTrackingConfiguration(); configuration.planeDetection = .horizontal; sceneView.session.run(configuration)
        } }
    
    func listFilesFromDocumentsFolder() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        
        do {
            let items = try fm.contentsOfDirectory(atPath: path)
            
            for item in items {
                print("Found \(item)")
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
        }
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        saveForm()
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
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
        
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
            let savedMap = UserDefaults.standard; savedMap.set(data, forKey: name); savedMap.synchronize(); DispatchQueue.main.async {
                //self.lblMessage.text = "World map saved" }
        } }
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
}
