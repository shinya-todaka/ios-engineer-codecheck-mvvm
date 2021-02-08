//
//  APIKit+Combine.swift
//  iOSEngineerCodeCheck
//
//  Created by 戸高新也 on 2021/02/08.
//  Copyright © 2021 YUMEMI Inc. All rights reserved.
//

import APIKit
import Combine

extension Session {
    
    struct Subscription<T: Request>: Combine.Subscription {
        var combineIdentifier: CombineIdentifier = CombineIdentifier()
        
        typealias Response = T.Response

        private var sessionTask: SessionTask?
        
        init(request: T, completion: @escaping (Result<Response, SessionTaskError>) -> Void) {
            self.sessionTask = send(request, handler: completion)
        }
        
        func request(_ demand: Subscribers.Demand) {}
        
        func cancel() {
            sessionTask?.cancel()
        }
    }

    class Publisher<T: Request>: Combine.Publisher {
        
        let request: T
        
        init(request: T) {
            self.request = request
        }
        
        typealias Output = T.Response
        typealias Failure = SessionTaskError
        
        func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = Subscription(request: request, completion: { result in
                switch result {
                    case let .success(response):
                        _ = subscriber.receive(response)
                    case let .failure(error):
                        subscriber.receive(completion: .failure(error))
                }
            })
            
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Session {
    func publisher<T: Request>(request: T) -> Publisher<T> {
        return Publisher(request: request)
    }
}
