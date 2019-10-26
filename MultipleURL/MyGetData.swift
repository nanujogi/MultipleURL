import Combine
import SwiftUI

class MyGetData: ObservableObject {
    
    //    var addData: [Bool] = []
    //    @Published var myBoolData: [Bool] = []
    
    var myBackgroundQueue: DispatchQueue = DispatchQueue(label: "myBackgroundQueue")
    var counter = 0
    
    var addData: [Bool] = []
    @Published var myBoolData: [Bool] = []
    
    struct PostmanEchoTimeStampCheckResponse: Decodable, Hashable {
        let valid: Bool
    }
    
    let testUrlString1 = "https://postman-echo.com/time/valid?timestamp=2016-10-10"
    let testUrlString2 = "https://postman-echo.com/time/valid?timestamp=2016-10-10"
    let testUrlString3 = "https://postman-echo.com/time/valid?timestamp=2016-10-10"
    let testUrlString4 = "https://postman-echo.com/time/valid?timestamp=2016-10-10"
    let testUrlString5 = "https://postman-echo.com/time/valid?timestamp=2016-10-10"
    let testUrlString6 = "https://postman-echo.com/time/valid?timestamp=2016-10-10"
    let testUrlString7 = "https://postman-echo.com/time/valid?timestamp=2016-10-10"
    
    var myURLArray = [String]()
    
    // "https://api.tfl.gov.uk/StopPoint/Meta/Modes"
    // "https://api.tfl.gov.uk/StopPoint/490007678W/arrivals"
    
    func fetch() {
        myURLArray.append(testUrlString1)
        myURLArray.append(testUrlString2)
        myURLArray.append(testUrlString3)
        myURLArray.append(testUrlString4)
        myURLArray.append(testUrlString5)
        myURLArray.append(testUrlString6)
        myURLArray.append(testUrlString7)
        
        for myurl in myURLArray {
            if let url = URL(string: myurl) {
                // Create an URLSession.shared.dataTaskPublisher.
                let remoteDataPublisher = URLSession.shared.dataTaskPublisher(for: url)
                    // the dataTaskPublisher output combination is (data: Data, response: URLResponse)
                    
                    // using different operators map, decode
                    //               .map {$0.data}
                    .map({ (inputTuple) -> Data in
                        return inputTuple.data
                    })
                    .decode(type: PostmanEchoTimeStampCheckResponse.self, decoder: JSONDecoder())
                    .map{$0.valid}
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()  // cleans up the type signature of the property
                
                // Complete sink has two closures
                let myremoteDataPublisher = remoteDataPublisher
                    .sink(receiveCompletion: { fini in
                        switch fini {
                        case .finished :
                            print(".sink() receiveCompletion", String(describing: fini))
                        case .failure:
                            print("Error in receiveCompletion")
                        }
                    }, receiveValue: { someValue in
                        self.myBoolData.append(someValue)
                        //                        self.addData.append(someValue)
                        print("\(self.myBoolData.count)")
                        //print(".sink() receiveValue \(someValue)\n")
                    })
            }
        }
    }
    
    /// Group
    func myGroup() {
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        myURLArray.append(testUrlString1)
        myURLArray.append(testUrlString2)
        myURLArray.append(testUrlString3)
        myURLArray.append(testUrlString4)
        myURLArray.append(testUrlString5)
        myURLArray.append(testUrlString6)
        myURLArray.append(testUrlString7)
        
        for myurl in myURLArray {
            
            guard let url = URL(string: myurl) else { continue }
            group.enter()
            
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                defer { group.leave() }
                
                if let error = error {
                    print("Error while loading in dataTask \(error.localizedDescription)")
                }
                
                if let data2 = data {
                    DispatchQueue.main.async {
                        self.parse(json: data2)
                    }
                }
            }
            task.resume()
            
        } // end of myURLArray loop
        
        group.notify(queue: queue) { print ("Loading of URL's completed!")
            DispatchQueue.main.async {
                self.myBoolData = self.addData
            }
            
        }
    } // end of myGroup()
    
    // MARK:- parse Json
    func parse(json: Data) {
        let decoder = JSONDecoder()
        if let jsonData = try? decoder.decode(PostmanEchoTimeStampCheckResponse.self, from: json) {
            let results = jsonData.valid
            addData.append(results)
            //            myBoolData.append(results)
        }
    } // end of parse
    
    /// Using Future
    func myFuturePublisher(_ urlstr: String ) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            self.someURL(self.testUrlString1) { (result, err) in
                if let err = err {
                    promise(.failure(err))
                }
                promise(.success(result))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func someURL(_ strurl: String, completion completionBlock: @escaping ((Bool, Error?) -> Void)) {
        // we process the url here & when all is done send true.
        let myURL = URL(string: testUrlString1)
        let remoteDataPublisher = URLSession.shared.dataTaskPublisher(for: myURL!)
            .map { $0.data }
            .decode(type: PostmanEchoTimeStampCheckResponse.self, decoder: JSONDecoder())
            
            .map{$0.valid}
            .receive(on: DispatchQueue.main)
            //            .subscribe(on: myBackgroundQueue)
            .eraseToAnyPublisher()
        
        let _ = remoteDataPublisher
            // validate
            .sink(receiveCompletion: { fini in
                print(".sink() received the completion", String(describing: fini))
                switch fini {
                case .finished:
                    print ("Finished")
                    break
                case .failure(let anError):
                    print("received error: ", anError)
                }
            }, receiveValue: { someValue in
                self.myBoolData.append(someValue)
                self.myBoolData.append(false)
                self.myBoolData.append(someValue)
                self.myBoolData.append(false)
                
                print(".sink() received \(someValue)")
            })
        
        if counter == 0 {
            // return true once done.
            completionBlock(true, nil)
        }
        print ("counter : \(counter)")
    }
}
