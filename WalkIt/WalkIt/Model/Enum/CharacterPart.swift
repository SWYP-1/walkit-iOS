//
//  CharacterPart.swift
//  WalkIt
//
//  Created by 조석진 on 1/12/26.
//


// 캐릭터 파트 구분 (HEAD/BODY/FEET)
public enum CharacterPart: String, Codable, CaseIterable, Hashable, Sendable {
    case head = "HEAD"
    case body = "BODY"
    case feet = "FEET"
}