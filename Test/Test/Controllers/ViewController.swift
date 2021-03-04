 import UIKit
 
 class ViewController: UIViewController {
    // MARK: - URL link
    private let urlString = "https://pryaniky.com/static/json/sample.json"
    @IBOutlet weak var stackView: UIStackView!
    var pickerArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - JSON request
        guard let urlLink = URL(string: self.urlString) else { return }
        parseJSON(url: urlLink, CompletionHandler: { myRequest, error in
            if let myRequest = myRequest {
                self.addView(fromRequest: myRequest)
            }
        })
    }
    
    // MARK: - Parse JSON func
    fileprivate func parseJSON(url: URL, CompletionHandler: @escaping (JSONStruct?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            guard let data = data else { return }
            DispatchQueue.main.async {
                do {
                    let decoder = JSONDecoder()
                    let jsonDict = try decoder.decode(JSONStruct.self, from: data)
                    CompletionHandler(jsonDict, nil)
                } catch let parseErr {
                    print("JSON Parsing Error", parseErr)
                    CompletionHandler(nil, parseErr)
                }
            }
        })
        task.resume()
    }
    
    // MARK: - Add views from JSON func
    fileprivate func addView(fromRequest: JSONStruct) {
        let viewsArray: [String] = fromRequest.view ?? []
        let datasArray: [JSONStruct.ElementSpecific] = fromRequest.data ?? []
        for requiredView in viewsArray {
            for myView in datasArray {
                if myView.name == requiredView {
                    if let url = myView.data?.url {
                        guard let imageURL = URL(string: url) else { return }
                        guard let imageData = try? Data(contentsOf: imageURL) else { return }
                        let myImage = UIImage(data: imageData)
                        let imageView = UIImageView(image: myImage)
                        imageView.contentMode = .scaleAspectFit
                        addTap(toView: imageView)
                        stackView.addArrangedSubview(imageView)
                    }
                    else if let selectedId = myView.data?.selectedId {
                        let selector = UIPickerView()
                        for i in 0...(myView.data?.variants?.count)!-1 {
                            pickerArray.append(myView.data?.variants?[i].text ?? "")
                        }
                        selector.delegate = self as UIPickerViewDelegate
                        selector.dataSource = self as UIPickerViewDataSource
                        selector.selectRow(selectedId, inComponent: 0, animated: false)
                        stackView.addArrangedSubview(selector)
                    }
                    else if let text = myView.data?.text {
                        let label = UILabel()
                        label.textAlignment = .center
                        label.text = text
                        addTap(toView: label)
                        stackView.addArrangedSubview(label)
                    }
                    else { return }
                }
            }
        }
    }
    
    // MARK: - Add tap func
    fileprivate func addTap(toView view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    // MARK: - Click handler func
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let _ = sender.view as? UIImageView {
            print("Нажали на изображение \(sender.view!)")
        }
        if let _ = sender.view as? UILabel {
            print("Нажали на текст \(sender.description)")
        }
        if let _ = sender.view as? UIPickerView {
            print("Нажали на пикер")
        }
    }
 }
 
 // MARK: - Picker funcs
 extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Выбрана строка №\(row)")
    }
 }
