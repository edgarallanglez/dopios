//
//  timeago.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 22/10/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import Foundation

extension String {
    func leftPadTo(requiredCharCount:Int) -> String {
        let missingSpaces = max(0,requiredCharCount - self.characters.count)
        return repeatElement(" ", count: missingSpaces).reduce(self,{$1 + $0})
    }
}

extension DateComponentsFormatter {
    class func idiomaticPhraseFormatter() -> DateComponentsFormatter {
        var f = DateComponentsFormatter()
        f.unitsStyle = .full
        f.includesApproximationPhrase = false
        f.includesTimeRemainingPhrase = true
        f.maximumUnitCount = 1
        f.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth , .month, .year]
        return f
    }
}

func timeAgoSinceDate(_ date: Date, numericDates: Bool) -> String {
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

func timeToDate(_ date: Date, numericDates: Bool) -> String {
    let kit_formatter = TTTTimeIntervalFormatter()
    kit_formatter.locale = Locale(identifier: "es")
    kit_formatter.futureDeicticExpression = ""
    kit_formatter.usesIdiomaticDeicticExpressions = true
    
   
    let future_time = kit_formatter.stringForTimeInterval(from: Date(), to: date)
    
//    let calendar = Calendar.current
//    let now = Date()
//    let earliest = (now as NSDate).earlierDate(date)
//    let latest = (earliest == now) ? date : now
//    let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
//    
//    if (components.second! <= 3) { return " \(components.second!) segundos" } else { return "Ahora" }
//    if (components.minute! <= 2) { return " \(components.minute!) minutos" }
//    else if (components.minute! <= 1) {
//        if numericDates { return " 1 minuto" } else { return " un minuto" }
//    }
//    if (components.hour! <= 2) { return " \(components.hour!) horas" }
//    else if (components.hour! <= 1) {
//        if numericDates { return " 1 hora" } else { return " una hora" }
//    }
//    else if (components.day! <= 2) { return " \(components.day!) dias" }
//    else if (components.day! <= 1) {
//        if numericDates { return " 1 dia" } else { return "Ayer" }
//    }
//    else if (components.weekOfYear! <= 2) { return " \(components.weekOfYear!) semanas" }
//    else if (components.weekOfYear! <= 1) {
//        if  numericDates { return " 1 semana" } else { return "La semana pasada" }
//    }
//    else if (components.month! <= 2) { return " \(components.month!) meses" }
//    else if (components.month! <= 1) {
//        if  numericDates { return " 1 mes" } else { return " un mes" }
//    }
//    else if (components.year! <= 2) { return " \(components.year!) años" }
//    else if (components.year! <= 1) {
//        if numericDates { return " 1 año" } else { return " un año" }
//    }
    return future_time!
}

extension Date {
    init(dateString: String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateStringFormatter.locale = Locale(identifier: "es_MX")
        let d = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval: 0, since: d)
    }
}
