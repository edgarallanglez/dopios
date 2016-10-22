//
//  timeago.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 22/10/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import Foundation

func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
    let calendar = NSCalendar.currentCalendar()
    let now = NSDate()
    let earliest = now.earlierDate(date)
    let latest = (earliest == now) ? date : now
    let components:NSDateComponents = calendar.components([NSCalendarUnit.Minute , NSCalendarUnit.Hour , NSCalendarUnit.Day , NSCalendarUnit.WeekOfYear , NSCalendarUnit.Month , NSCalendarUnit.Year , NSCalendarUnit.Second], fromDate: earliest, toDate: latest, options: NSCalendarOptions())
    
    if (components.year >= 2) {
        return "Hace \(components.year) años"
    } else if (components.year >= 1){
        if (numericDates){
            return "Hace 1 año"
        } else {
            return "Hace un año"
        }
    } else if (components.month >= 2) {
        return "Hace \(components.month) meses"
    } else if (components.month >= 1){
        if (numericDates){
            return "Hace 1 mes"
        } else {
            return "Hace un mes"
        }
    } else if (components.weekOfYear >= 2) {
        return "Hace \(components.weekOfYear) semanas"
    } else if (components.weekOfYear >= 1){
        if (numericDates){
            return "Hace una semana"
        } else {
            return "La semana pasada"
        }
    } else if (components.day >= 2) {
        return "Hace \(components.day) dias"
    } else if (components.day >= 1){
        if (numericDates){
            return "Hace 1 dia"
        } else {
            return "Ayer"
        }
    } else if (components.hour >= 2) {
        return "Hace \(components.hour) horas"
    } else if (components.hour >= 1){
        if (numericDates){
            return "Hace 1 hora"
        } else {
            return "Hace una hora"
        }
    } else if (components.minute >= 2) {
        return "\(components.minute) minutes ago"
    } else if (components.minute >= 1){
        if (numericDates){
            return "Hace 1 minuto"
        } else {
            return "Hace un minuto"
        }
    } else if (components.second >= 3) {
        return "Hace \(components.second) segundos"
    } else {
        return "Ahora"
    }
    
}
extension NSDate
{
    convenience
    init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let d = dateStringFormatter.dateFromString(dateString)!
        self.init(timeInterval:0, sinceDate:d)
    }
}
