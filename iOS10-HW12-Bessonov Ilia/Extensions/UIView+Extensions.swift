//
//  UIView+Extensions.swift
//  iOS10-HW12-Bessonov Ilia
//
//  Created by i0240 on 17.06.2023.
//

import UIKit

extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0) }
    }
}
