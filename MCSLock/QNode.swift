//
//  QNode.swift
//  MCSLocck
//
//  Created by Ebubechukwu Dimobi on 19.12.2021.
//

class QNode {
    var isLocked: Bool = false
    var next: QNode? = nil
}

/// Two know if two QNodes are equal to eachother we check the adress
extension QNode: Equatable {
    static func == (lhs: QNode, rhs: QNode) -> Bool {
        lhs === rhs
    }
}
