import UIKit
import Speech

public class viewController: UIViewController, SFSpeechRecognizerDelegate{

    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var recordButton: UIButton!

    //Para o Recognizer é necessário definir o idioma local e alocar o buffer para
    //o motor de áudio

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier :"pt-br"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest = SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask = SFSpeechRecognitionTask?

    public override func viewDidLoad(){
        super.viewDidLoad() 
        recordButton.isEnabled = false //O botão de gravação só estará ativo e disponível após o usuário fornecer permissão
    }

    override func viewDidAppear(_ animated: bool){
        speechRecognizer.delegate = self
         
         SFSpeechRecognizer.requestAuthorization{ authStatus in 
            OperationQueue.main.addOperation{
                switch authStatus {
                case .authorized:
                    self.recordButton.isEnabled = true
                case .denied:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Denied", for: .disabled)
                case .restricted:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Denied", for: .disabled)
                case .notDetermined:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Denied", for: .disabled)
                default:
                         
                }
            }
        }
    }//Fim da função

    private func StartRecording() trows { //Tratamento de erros
        
    }
}
