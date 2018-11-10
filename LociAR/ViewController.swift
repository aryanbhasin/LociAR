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
//        loadSave()
    }
    
    @IBAction func saveButton(_ sender: Any) {
    }
    
//    func listFilesFromDirectory() -> [NSString] {
//        let fileManager = FileManager.default
//        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        do {
//            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
//            // process files
//        } catch {
//            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
//        }
//    }
    
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
