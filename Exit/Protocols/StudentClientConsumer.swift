//
//  StudentClientConsumer.swift
//  MyKey
//
//  Created by Dani Shifer on 1/20/20.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import MyKeyKit

protocol StudentClientConsumer {
    var client: MyKeyStudentClient! { get set }
}
