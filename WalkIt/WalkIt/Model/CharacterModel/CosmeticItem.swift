//
//  CosmeticItem 2.swift
//  WalkIt
//
//  Created by 조석진 on 1/12/26.
//


public struct CosmeticItem: Codable, Hashable, Sendable {
    public let itemId: Int
    public let imageName: String
    public let tag: String?
    public let position: CharacterPart
    public var worn: Bool
    public var owned : Bool
    public let name: String
    public let point: Int
    
    public init(
        itemId: Int,
        imageName: String,
        tag: String?,
        position: CharacterPart,
        worn: Bool = false,
        owned: Bool = false,
        name: String? = nil,
        point: Int? = nil
    ) {
        self.itemId = itemId
        self.imageName = imageName
        self.tag = tag
        self.position = position
        self.worn = worn
        self.owned = owned
        self.name = name ?? ""
        self.point = point ?? 0
    }
}