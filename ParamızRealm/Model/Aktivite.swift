//
//  Aktivite.swift
//  ParamızRealm
//
//  Created by Erkan on 24.12.2022.
//

import Foundation
import RealmSwift
class Aktivite : Object{
    @objc dynamic var adi : String = ""
    @objc dynamic var Bittimi : Bool = false
    let odemeler = List<Odeme>()
    //kek
}
