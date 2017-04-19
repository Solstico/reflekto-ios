//
//  EventService.swift
//  reflekto
//
//  Created by Michał Kwiecień on 19.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import Foundation
import EventKit

class EventService {
    var eventStore: EKEventStore
    
    init() {
        eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { access, error in }
    }
    
    func getNextEvent() -> EKEvent? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.day = +7
        
        let endDay = calendar.date(byAdding: dateComponents, to: Date())!
        let startDay = Date()
        
        let predicate = eventStore.predicateForEvents(withStart: startDay, end: endDay, calendars: nil)
        let events = eventStore.events(matching: predicate)
        return events.first
    }
    
}
