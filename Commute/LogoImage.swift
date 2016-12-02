//
//  LogoImage.swift
//  Commute
//
//  Created by Boris Yurkevich on 01/12/2016.
//  Copyright © 2016 Boris Yurkevich. All rights reserved.
//

import UIKit

class LogoImage {

    let id: Int
    let type: Transport
    var image: UIImage?

    init(type: Transport, id: Int) {
        self.id = id
        self.type = type
    }
}
