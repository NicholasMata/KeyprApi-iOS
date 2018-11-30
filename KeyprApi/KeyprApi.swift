//
//  KeyprApi.swift
//  KeyprApi
//
//  Created by Nicholas Mata on 11/27/18.
//  Copyright © 2018 Nicholas Mata. All rights reserved.
//

import Foundation

public typealias KeyprJWTGenerator = ((_ jwt: String)->Void) -> Void
public typealias KeyprApiResponse<T> = ((T?, Error?) -> Void)?
public typealias WebTokenCompletion = KeyprApiResponse<WebToken>

/// Different types of Keypr environments
///
/// - staging: Staging Keypr environment
/// - production: Production Keypr environment
public enum KeyprEnv {
    case staging
    case production
    
    func apiUrl() -> String {
        switch self {
        case .staging:
            return "https://api.keyprstg.com"
        case .production:
            return "https://api.keypr.com"
        }
    }
    
    func accountUrl() -> String {
        switch self {
        case .staging:
            return "https://account.keyprstg.com"
        case .production:
            return "https://account.keypr.com"
        }
    }
}


/// Different types on async tasks in Keypr
///
/// - checkIn: Check into a reservation
/// - checkOut: Check out of a reservation
public enum KeyprAsyncTask: String {
    case checkIn = "check_in"
    case checkOut = "check_out"
}

public enum ApiError: LocalizedError {
    case failed(String?)
    
    public var errorDescription: String? {
        switch self {
        case .failed(let message):
            return message
        }
    }
}

open class KeyprApi {
    public var jwtGenerator: KeyprJWTGenerator
    public var jwt = WebToken()
    
    public private(set) var accessToken = WebToken()
    private var semaphore = DispatchSemaphore(value: 0)
    private var urlSession: URLSession
    private var queue: DispatchQueue
    private var env: KeyprEnv
    
    private var jsonEncoder = JSONEncoder()
    
    public convenience init(jwtGenerator: @escaping KeyprJWTGenerator, environment: KeyprEnv = .production) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval(30)
        config.timeoutIntervalForResource = TimeInterval(30)
        self.init(jwtGenerator: jwtGenerator, sessionConfig: config, environment: environment)
    }
    
    /**
     Creates a new instance for accessing KEYPR Api using Federated Authentication Flow.
     
     - Parameter sessionConfig: Session configuration that will be used for all api call. Content-Type automatically set to json.
     - Parameter environment: A enum value indicating what api should be used staging or production.
     - Parameter jwtGenerator: A func that is responsible for generating JWT, locally or from server call.
     */
    public init(jwtGenerator: @escaping KeyprJWTGenerator, sessionConfig: URLSessionConfiguration, environment: KeyprEnv = .production) {
        self.jwtGenerator = jwtGenerator
        self.env = environment
        self.queue = DispatchQueue(label: "com.matadesigns.keyprapi", qos: .utility)
        let requiredHeaders = ["Content-Type": "application/json"]
        if sessionConfig.httpAdditionalHeaders == nil {
            sessionConfig.httpAdditionalHeaders = requiredHeaders
        }
        requiredHeaders.forEach { (i) in
            sessionConfig.httpAdditionalHeaders?[i.key] = i.value
        }
        self.urlSession = URLSession(configuration: sessionConfig)
    }
    
    /**
     Starts an async task aka check-in/check-out. Must use check() to know if it completes. or **use perform()**
     
     - Note: This calls the keypr endpoint *v1/reservations/{reservationId}/async_check_in*.
     - Important: Unless you know what your doing use **perform()** function for a all in one solution.
     
     - Parameter task: A task to start
     - Parameter reservationId: The id of the reservation you want to attempt to check-in to.
     - Parameter completionHandler: The completion handler to call when the request is complete. This handler is executed on the delegate queue.
     
        This completion handler takes the following parameters:
     - Parameter task: A reservation task from successful response.
     - Parameter error: A error from parsing json, network, or unsuccessful response.
     */
    public func start(task: KeyprAsyncTask,reservationId: String,
                             completionHandler: @escaping(_ task:ReservationTask?,_ error: Error?) -> ()) {
        checkAndQueue {
            let absoluteUrl = "\(self.env.apiUrl())/v1/reservations/\(reservationId)/async_\(task.rawValue)"
            self.makeRequest(url: absoluteUrl, method: "PUT", completionHandler: completionHandler)
        }
    }
    
    /**
     Check the status of a check-in/check-out task.
     
     - Note: This calls the keypr endpoint *v1/tasks/{taskId}*.
     - Important: Unless you know what your doing use checkIn function for a all in one solution.
     
     - Parameter taskId: The id for a check-in or check-out task
     - Parameter completionHandler: The completion handler to call when the request is complete. This handler is executed on the delegate queue.
     
        This completion handler takes the following parameters:
     - Parameter task: A reservation task from successful response.
     - parameter error: A error from parsing json, network, or unsuccessful response.
     */
    public func check(taskId: String,
                            completionHandler: @escaping(_ task:ReservationTask?,_ error: Error?) -> ()) {
        checkAndQueue {
            let absoluteUrl = "\(self.env.apiUrl())/v1/tasks/\(taskId)"
            self.makeRequest(url: absoluteUrl, method: "GET", completionHandler: completionHandler)
        }
    }
    /**
     Performs an async task like check-in/check-out.
     
     - Parameter task: A task to perform
     - Parameter reservationId: The id of the reservation
     - Parameter timeout: The numbers of seconds to wait for before timing out.
     - Parameter completionHandler: The completion handler to call when the request is complete. This handler is executed on the delegate queue.
     
        This completion handler takes the following parameters:
     - Parameter successful: Whether or not the check in was successful.
     - Parameter task: The task response if there was one.
     - parameter error: A error from parsing json, network, timeout, or unsuccessful response.
    */
    public func perform(task: KeyprAsyncTask, reservationId: String, timeout: TimeInterval,
                        completionHandler: @escaping(_ successful:Bool,_ task:ReservationTask?,_ error:Error?)->()) {
        let taskHandler: (ReservationTask?,Error?) -> () = { (task, error) in
            guard let checkInTask = task, error == nil  else {
                return completionHandler(false, nil, error)
            }
            if checkInTask.data.attributes.failed {
                return completionHandler(false, checkInTask, error)
            }
            let taskId = checkInTask.data.id
            let stopAt = Date().addingTimeInterval(timeout)
            let queue = DispatchQueue(label: "CheckInTask-\(checkInTask.data.id)", qos: .background)
            var checkStatusHandler: (()->())!
            checkStatusHandler = {
                if Date() >= stopAt {
                    return completionHandler(false, nil, nil)
                }
                self.check(taskId: taskId) { (task, error) in
                    guard let task = task, error == nil  else {
                        return completionHandler(false, nil, error)
                    }
                    if task.data.attributes.failed {
                        return completionHandler(false, task, error)
                    }
                    if task.data.attributes.successful {
                        return completionHandler(true, task, error)
                    }
                    sleep(1)
                    queue.async {
                        checkStatusHandler()
                    }
                }
            }
            queue.async {
                checkStatusHandler()
            }
        }
        start(task: task, reservationId: reservationId, completionHandler: taskHandler)
    }
    
    /**
     Get reservations for the logged in user.
     
     - Note: This calls the keypr endpoint *v1/reservations{query}*.
     - Important: Unless you know what your doing use checkIn function for a all in one solution.
     
     - Parameter query: A query to be appended at the end of url i.e. ?state=reserved, /active, /archived
     - Parameter completionHandler: The completion handler to call when the request is complete. This handler is executed on the delegate queue.
     
        This completion handler takes the following parameters:
     - Parameter reservations: A paged array of reservations.
     - Parameter error: A error from parsing json, network, or unsuccessful response.
     */
    public func reservations(query:String = "",
                             completionHandler: @escaping(_ reservations: PagedResponse<[Reservation]>?,_ error: Error?)-> ()) {
        checkAndQueue {
            let abosoluteUrl = "\(self.env.apiUrl())/v1/reservations\(query)"
            self.makeRequest(url: abosoluteUrl, method: "GET", completionHandler: completionHandler)
        }
    }
    
    /**
     Get a reservation.
     
     - Note: This calls the keypr endpoint *v1/reservations{query}*.
     - Important: Unless you know what your doing use checkIn function for a all in one solution.
     
     - Parameter query: A query to be appended at the end of url i.e. ?state=reserved, /active, /archived
     - Parameter completionHandler: The completion handler to call when the request is complete. This handler is executed on the delegate queue.
     
     This completion handler takes the following parameters:
     - Parameter reservation: A reservation.
     - Parameter error: A error from parsing json, network, or unsuccessful response.
     */
    public func reservation(id: String, completionHandler: @escaping(_ reservations: Reservation?,_ error: Error?)-> ()) {
        checkAndQueue {
            let abosoluteUrl = "\(self.env.apiUrl())/v1/reservations/\(id)"
            self.makeRequest(url: abosoluteUrl, method: "GET", completionHandler: { (response:ReservationDataResponse?, err) in
                completionHandler(response?.data, err)
            })
        }
    }
    
    /**
     Get access token from JWT (JSON Web Token).
     
     - Note: This calls the keypr endpoint *v1/reservations{query}*.
     - Important: Unless you know what your doing use checkIn function for a all in one solution.
     
     - Parameter jwt: A JWT (JSON Web Token)
     - Parameter completionHandler: The completion handler to call when the request is complete. This handler is executed on the delegate queue.
     
        This completion handler takes the following parameters:
     - Parameter token: A OAuth Response contains access, id, and refresh tokens.
     - Parameter error: A error from parsing json, network, or unsuccessful response.
     */
    public func getAccessToken(_ jwt: String,
                               completionHandler: Optional<(_ token: OAuthResponse?,_ error: Error?)->()> = nil ) {
        let absoluteUrl = "\(self.env.accountUrl())/federated-id/token"
        let body = FederatedTokenBody(jwt: jwt)
        let bodyData = try? self.jsonEncoder.encode(body)
        self.makeRequest(url: absoluteUrl, method: "POST", body: bodyData, completionHandler: completionHandler)
    }
    /**
     Check Authorization, gets and sets access_token and calls JWT generator if needed.
     - Note: Used mainly internally but thought might be useful to make public.
    */
    public func checkAuthorization(jwtComplete:WebTokenCompletion = nil, accessTokenCompletion: WebTokenCompletion = nil) {
        if !accessToken.isValid() {
            if !jwt.isValid()  {
                queue.async {
                    self.jwtGenerator{(jwt) in
                        do{
                            try self.jwt.fill(jwt: jwt)
                            if self.jwt.isExpired() {
                                throw JWTError.expired
                            }
                            jwtComplete?(self.jwt, nil)
                        } catch let error {
                            jwtComplete?(nil, error)
                            self.queue.suspend()
                        }
                        self.semaphore.signal()
                    }
                    self.semaphore.wait()
                }
            }
            queue.async {
                let jwt = self.jwt.value!
                self.getAccessToken(jwt) { (response, error) in
                    if error != nil {
                        self.queue.suspend()
                    } else {
                        self.accessToken.value = response?.accessToken
                        self.accessToken.expires(in: response?.expiresIn)
                    }
                    accessTokenCompletion?(self.accessToken.isValid() ? self.accessToken : nil, error)
                    self.semaphore.signal()
                }
                self.semaphore.wait()
            }
        }
    }
    
    private func checkAndQueue(block: @escaping () -> Void) {
        checkAuthorization()
        queue.async(execute: block)
    }
    
    private func makeRequest<T: Decodable>(url: String, method: String, body: Data? = nil, decoder: JSONDecoder = JSONDecoder(), completionHandler: ((T?, Error?)->())? = nil) {
        // Keypr Api Response is all snake_case
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method
        request.httpBody = body
        
        if let accessToken = self.accessToken.value {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        self.urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                completionHandler?(nil, error)
                return
            }
            do {
                switch response.statusCode  {
                case 200..<300:
                    completionHandler?(try decoder.decode(T.self, from: data), nil)
                default:
                    var errorResponse = try? decoder.decode(ErrorResponse.self, from: data)
                    if errorResponse == nil {
                        let errorObjectResponse = try? decoder.decode(ErrorObjectResponse.self, from: data)
                        errorResponse = errorObjectResponse?.errors.first
                    }
                    completionHandler?(nil, ApiError.failed(errorResponse?.detail))
                }
            } catch let error {
                completionHandler?(nil, error)
            }
        }.resume()
    }
}