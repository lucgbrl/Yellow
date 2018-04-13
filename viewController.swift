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

   private func StartRecording() throws {
        
        if let recognitionTask = recognitionTask { //Constante recognitionTast
            recognitionTask.cancel() //Por algum motivo a captura foi cancelada após ter sido concedido permissão
            self.recognitionTask = nil //O reconhecimento é encerrado
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        //Os erros abaixo referem-se à situação de o microfone não estar disponível ou não ter sido reconhecido pelo Sistema Operacional em nenhuma tentativa
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Não houveram entradas no motor de áudio") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Incapaz de criar sessão SfSpeechAudioBufferRecognitionRequest object")}
        
        recognitionRequest.shouldReportPartialResults = true //Irá mostrar até a última parte que foi gravada, antes da falha
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in var isFinal = false
            
            if let result = result {
                self.textview.text = result.bestTranscription.formattedString //caso haja falha durante a gravação será transcrito até o momento anterior à falha de gravação | Continuidade
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal { //Caso o erro não seja a interrupção da gravação mas seja outra coisa
                self.audioEngine.stop() // A engine de captura irá parar a gravação
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.dictatebutton.isEnabled = true
                self.dictatebutton.setTitle("Comece a falar", for: [])
            }
        
    }
    
        //Outra constante é definida abaixo, definindo o formato de gravação
    let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        textview.text = "Estou ouvindo!"
    }
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            dictatebutton.isEnabled = true
            dictatebutton.setTitle("Iniciar Gravação", for: [])
        } else {
            dictatebutton.isEnabled = false
            dictatebutton.setTitle("Indisponível.", for: .disabled)
        }
    }
    
    @IBAction func dictateaction() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            dictatebutton.isEnabled = false
            dictatebutton.setTitle("Encerrando...", for: .disabled)
        } else {
            try! StartRecording()
            dictatebutton.setTitle("Parando Gravação", for: [])
        }       
    }
}
