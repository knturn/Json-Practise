//
//  Petition.swift

//
//  Created by Kaan on 27.07.2022.
//

import Foundation

struct Petition : Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
