//
//  AlbumStreamRepository.swift
//  MusicFeeder
//
//  Created by Hiroki Kumamoto on 2017/03/22.
//  Copyright © 2017 kumabook. All rights reserved.
//

import Foundation
import ReactiveSwift

open class AlbumStreamRepository: EnclosureStreamRepository<Album> {
    open static var sharedPipe: (Signal<Album, NSError>, Signal<Album, NSError>.Observer)! = Signal<Album, NSError>.pipe()
}
