//
//  ContentView.swift
//  MultipleURL
//
//  Created by Nanu Jogi on 26/10/19.
//  Copyright © 2019 Greenleaf Software. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @EnvironmentObject var store: MyGetData
    
    let testUrlString = "https://postman-echo.com/time/valid?timestamp=2016-10-10"
    
    var body: some View {
        Group {
            NavigationView {
                VStack {
                    ForEach(self.store.myBoolData, id:\.self) { getp in
                        Text(String(getp))
                    }
                }
                .navigationBarTitle(Text("Data"))
            } // end of NavigationView
            
        } // end of Group
            .onAppear {
                self.store.myGroup()
//                self.store.fetch()
//                self.store.myFuturePublisher(self.testUrlString)
//                print("myBoolData Count: \(self.store.myBoolData.count)")
        }
    }
}

