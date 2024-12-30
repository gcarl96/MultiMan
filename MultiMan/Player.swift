//
//  Player.swift
//  MultiMan
//
//  Created by Gareth Carless on 05/05/2023.
//

import Foundation

class Player: Codable, Equatable, Hashable, Identifiable {
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.name==rhs.name
    }
        
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(ObjectIdentifier(self))
    }

}

