//
//  ViewController.swift
//  ImageClassifer
//
//  Created by Sai Gurrapu on 5/15/19.
//  Copyright © 2019 Sai Gurrapu. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Trigger Camera
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        
        // Camera on View
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
    
      //  VNImageRequestHandler(cgImage: <#T##CGImage#>, options: [:]).perform(requests)
        
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
      //  print("Camera was able to capture a frame", Date())
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {return}
        let request = VNCoreMLRequest(model: model)
        {
            (finishedReq, err) in
            
            //Check Error
            
         //   print(finishedReq.results)
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
            
            guard let firstObservation = results.first else {return}
            
            print(firstObservation.identifier, firstObservation.confidence)
        }
        
       try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }

}



