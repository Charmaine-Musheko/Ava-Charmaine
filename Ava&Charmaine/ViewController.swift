//
//  ViewController.swift
//  Ava&Charmaine1
//
//  Created by Charmaine Musheko on 16/08/2021.
//

import UIKit
import Speech
import CoreData


class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
   
  
    @IBOutlet weak var lb_speech: UILabel!
    @IBOutlet weak var view_color: UIView!
    @IBOutlet weak var btn_start: UIButton!
    
    
    
    
    //MARK: - Local Properties
        let audioEngine = AVAudioEngine()
        let speechReconizer : SFSpeechRecognizer? = SFSpeechRecognizer()
        let request = SFSpeechAudioBufferRecognitionRequest()
        var task : SFSpeechRecognitionTask!
        var isStart : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        btn_start.backgroundColor = .systemBlue
        btn_start.setTitleColor(.white, for: .normal)
        requestPermission()
    }
    func requestPermission()
    {
        self.btn_start.isEnabled = false
        SFSpeechRecognizer.requestAuthorization{
            (authState) in OperationQueue.main.addOperation {
                if authState == .authorized{
                    print("ACCEPTED")
                    self.btn_start.isEnabled = true
                }else if authState == .denied{
                    self.alertView(message: "User denied permission")
                }else if authState == .notDetermined{
                    self.alertView(message: "User does not have speech recognization funtionality")
                }
                    
                }
        }
    }
    
    
        @IBAction func btn_start_stop(_ sender: Any) {
        isStart = !isStart
                if isStart {
                    startSpeechRecognization()
                    btn_start.setTitle("STOP", for: .normal)
                    btn_start.backgroundColor = .systemGreen
                }else {
                    cancelSpeechRecognization()
                    btn_start.setTitle("START", for: .normal)
                    btn_start.backgroundColor = .systemOrange
                }
    }
    
    func alertView(message: String){
        let controller = UIAlertController.init(title: "Error occured! ....", message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                                            controller.dismiss(animated: true, completion: nil)
            
        }))
        self.present(controller, animated: true, completion: nil)
        
        
    }
    func cancelSpeechRecognization() {
         task.finish()
         task.cancel()
         task = nil
         
         request.endAudio()
         audioEngine.stop()
         //audioEngine.inputNode.removeTap(onBus: 0)
         
         //MARK: UPDATED
         if audioEngine.inputNode.numberOfInputs > 0 {
             audioEngine.inputNode.removeTap(onBus: 0)
         }
     }
    func startSpeechRecognization(){
          let node = audioEngine.inputNode
          let recordingFormat = node.outputFormat(forBus: 0)
          
          node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
              self.request.append(buffer)
          }
          
          audioEngine.prepare()
          do {
              try audioEngine.start()
          } catch let error {
              alertView(message: "Error comes here for starting the audio listner =\(error.localizedDescription)")
          }
          
          guard let myRecognization = SFSpeechRecognizer() else {
              self.alertView(message: "Recognization is not allow on your local")
              return
          }
          
          if !myRecognization.isAvailable {
              self.alertView(message: "Recognization is free right now, Please try again after some time.")
          }
          
          task = speechReconizer?.recognitionTask(with: request, resultHandler: { (response, error) in
              guard let response = response else {
                  if error != nil {
                      self.alertView(message: error.debugDescription)
                  }else {
                      self.alertView(message: "Problem in giving the response")
                  }
                  return
              }
              
              let message = response.bestTranscription.formattedString
              print("Message : \(message)")
              self.lb_speech.text = message
              
              
              var lastString: String = ""
              for segment in response.bestTranscription.segments {
                  let indexTo = message.index(message.startIndex, offsetBy: segment.substringRange.location)
                  lastString = String(message[indexTo...])
              }
              
              if lastString == "red" {
                  self.view_color.backgroundColor = .systemRed
              } else if lastString.elementsEqual("green") {
                  self.view_color.backgroundColor = .systemGreen
              } else if lastString.elementsEqual("pink") {
                  self.view_color.backgroundColor = .systemPink
              } else if lastString.elementsEqual("blue") {
                  self.view_color.backgroundColor = .systemBlue
              } else if lastString.elementsEqual("black") {
                  self.view_color.backgroundColor = .black
              }
              
              
          })
    }

}
