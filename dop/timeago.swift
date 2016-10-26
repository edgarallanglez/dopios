//
//  timeago.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 22/10/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import Foundation

func timeAgoSinceDate(_ date:Date, numericDates:Bool) -> String {
    let calendar = Calendar.current
    let now = Date()
    let earliest = (now as NSDate).earlierDate(date)
    let latest = (earliest == now) ? date : now
    let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
    
    if (components.year! >= 2) {
        return "Hace \(components.year!) años"
    } else if (components.year! >= 1){
        if (numericDates){
            return "Hace 1 año"
        } else {
            return "Hace un año"
        }
    } else if (components.month! >= 2) {
        return "Hace \(components.month!) meses"
    } else if (components.month! >= 1){
        if (numericDates){
            return "Hace 1 mes"
        } else {
            return "Hace un mes"
        }
    } else if (components.weekOfYear! >= 2) {
        return "Hace \(components.weekOfYear!) semanas"
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return "Hace 1 semana"
        } else {
            return "La semana pasada"
        }
    } else if (components.day! >= 2) {
        return "Hace \(components.day!) dias"
    } else if (components.day! >= 1){
        if (numericDates){
            return "Hace 1 dia"
        } else {
            return "Ayer"
        }
    } else if (components.hour! >= 2) {
        return "Hace \(components.hour!) horas"
    } else if (components.hour! >= 1){
        if (numericDates){
            return "Hace 1 hora"
        } else {
            return "Hace una hora"
        }
    } else if (components.minute! >= 2) {
        return "Hace \(components.minute!) minutos"
    } else if (components.minute! >= 1){
        if (numericDates){
            return "Hace 1 minuto"
        } else {
            return "Hace un minuto"
        }
    } else if (components.second! >= 3) {
        return "Hace \(components.second!) segundos"
    } else {
        return "Ahora"
    }
    
}
extension Date
{
    
    init(dateString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        let d = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval: 0, since: d)
    }
}
