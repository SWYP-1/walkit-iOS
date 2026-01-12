//
//  AlimManagerViewModel 2.swift
//  WalkIt
//
//  Created by 조석진 on 1/5/26.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class DressingRoomViewModel: ObservableObject {
    let userManager = UserManager.shared
    let serverManager = ServerManager.shared
    @Published var items: [CosmeticItem] = []
    @Published var character: CharacterInfo = CharacterInfo(level: 1, grade: "SEED", nickName: "", currentGoalSequence: 0)
    @Published var lottieJson: [String: Any] = [:]
    @Published var point: Int = 0
    @Published var isShowOwnedItem: Bool = false
    @Published var isShowBuy: Bool = false
    @Published var isShowInfo: Bool = false
    @Published var sumPoint: Int = 0
    @Published var canBuyItem: Bool = false
    @Published var showSaveAlert: Bool = false
    
    var headItem: CosmeticItem? = nil
    var bodyItem: CosmeticItem? = nil
    var feetItem: CosmeticItem? = nil
    
    let backGroundImageHeight = 480.0
    let backGroundImageWidth = 375.0
    
    // 변경된 사항이 있는지 확인용
    var wornHeadItem: CosmeticItem? = nil
    var wornBodyItem: CosmeticItem? = nil
    var wornFeetItem: CosmeticItem? = nil
    
    var didLoad = false
    func loadView() {
        Task {
            await fetchItemst()
            loadCharacter()
            debugPrint("lottieJson: \(lottieJson)")
            didLoad = true
        }
    }
    
    func loadCharacter() {
        character.level = userManager.level
        character.grade = userManager.grade
        character.characterImageName = userManager.characterInfo.characterImageName
        character.backgroundImageName = userManager.characterInfo.backgroundImageName
        character.headImageName = userManager.characterInfo.headImageName
        character.bodyImageName = userManager.characterInfo.bodyImageName
        character.feetImageName = userManager.characterInfo.feetImageName
        Task {
            do {
                let userId = userManager.userId ?? 0
                let baseJsonData = try loadLottieJson(for: character.grade)
                var baseJson = try JSONSerialization.jsonObject(with: baseJsonData) as! [String: Any]
                
                if let headTopItem = UserDefaults.standard.string(forKey: "\(userId)headTopItem") {
                    baseJson = await changePartItem(json: baseJson, part: "headtop", assaset: headTopItem)
                    headItem = items.filter{ $0.imageName == headTopItem }.first
                    wornHeadItem = headItem
                }
                if let headDecorItem = UserDefaults.standard.string(forKey: "\(userId)headDecorItem") {
                    baseJson = await changePartItem(json: baseJson, part: "headdecor", assaset: headDecorItem)
                    headItem = items.filter{ $0.imageName == headDecorItem }.first
                    wornHeadItem = headItem
                }
                if let bodyImageName = UserDefaults.standard.string(forKey: "\(userId)bodyItem") {
                    baseJson = await changePartItem(json: baseJson, part: "body", assaset: bodyImageName)
                    bodyItem = items.filter{ $0.imageName == bodyImageName }.first
                    wornBodyItem = bodyItem
                }
                if let feetImageName = UserDefaults.standard.string(forKey: "\(userId)feetItem") {
                    baseJson = await changePartItem(json: baseJson, part: "foot", assaset: feetImageName)
                    feetItem = items.filter{ $0.imageName == feetImageName }.first
                    wornFeetItem = feetItem

                } else {
                    baseJson = await setDefaultFoot(json: baseJson, grade: character.grade)
                }
                lottieJson = baseJson
            } catch {
                debugPrint("loadCharacter 실패")
            }
        }
    }
    
    func fetchItemst() async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            let fetched = try await serverManager.getItems(token: accessToken)
            items = fetched
            debugPrint("getItems: \(items)")
        } catch {
            debugPrint("getItems 실패: \(error)")
            items = []
        }
    }
    
    func fetchItems() async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else {
            items = []
            return
        }
        
        do {
            let fetched = try await serverManager.getItems(token: accessToken)
            items = fetched
        } catch {
            debugPrint("getItems 실패: \(error)")
            items = []
        }
    }
    
    func selecItem(item: CosmeticItem) {
        switch(item.position) {
        case .head:
            if(headItem == item) {
                lottieJson = removeItem(json: lottieJson, item: headItem ?? item)
                headItem = nil
            } else {
                if(headItem?.tag != item.tag) {
                    let tempJson = removeItem(json: lottieJson, item: headItem ?? item)
                    headItem = item
                    Task { @MainActor in
                        lottieJson = await changeItem(json: tempJson, item: headItem ?? item)
                    }
                } else {
                    headItem = item
                    Task { @MainActor in
                        lottieJson = await changeItem(json: lottieJson, item: headItem ?? item)
                    }
                }
            }
            break
        case .body:
            if(bodyItem == item) {
                lottieJson = removeItem(json: lottieJson, item: bodyItem ?? item)
                bodyItem = nil
            } else {
                bodyItem = item
                Task { @MainActor in
                    lottieJson = await changeItem(json: lottieJson, item: bodyItem ?? item)
                }
            }
            break
        case .feet:
            if(feetItem == item) {
                let tmpJson = removeItem(json: lottieJson, item: feetItem ?? item)
                Task { @MainActor in
                    lottieJson = await setDefaultFoot(json: tmpJson, grade: character.grade)
                }
                feetItem = nil
            } else {
                feetItem = item
                Task { @MainActor in
                    lottieJson = await changeItem(json: lottieJson, item: feetItem ?? item)
                }
            }
            break
        }
    }
    
    func getPoint() async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            let point = try await serverManager.getPoint(token: accessToken)
            self.point = point.point
        } catch {
            debugPrint("getPoint 실패")
        }
    }
}

extension DressingRoomViewModel {
    func loadLottieJson(for grade: String) throws -> Data {
        switch(grade) {
        case "SEED":
            guard let url = Bundle.main.url(forResource: "seed", withExtension: "json") else {
                throw NSError(domain: "Lottie", code: 1, userInfo: [NSLocalizedDescriptionKey: "seed.json not found in bundle"])
            }
            return try Data(contentsOf: url)
        case "SPROUT":
            guard let url = Bundle.main.url(forResource: "sprout", withExtension: "json") else {
                throw NSError(domain: "Lottie", code: 1, userInfo: [NSLocalizedDescriptionKey: "sprout.json not found in bundle"])
            }
            return try Data(contentsOf: url)
        case "TREE":
            guard let url = Bundle.main.url(forResource: "tree", withExtension: "json") else {
                throw NSError(domain: "Lottie", code: 1, userInfo: [NSLocalizedDescriptionKey: "tree.json not found in bundle"])
            }
            return try Data(contentsOf: url)
        default:
            guard let url = Bundle.main.url(forResource: "seed", withExtension: "json") else {
                throw NSError(domain: "Lottie", code: 1, userInfo: [NSLocalizedDescriptionKey: "seed.json not found in bundle"])
            }
            return try Data(contentsOf: url)
        }
    }
    
    func downloadDefaultImages(for character: CharacterData, downloader: ImageDownloader) async throws -> [String: String] {
        var result: [String: String] = [:]

        if let head = character.headImageUrl {
            let assetId = CharacterPart.head.getLottieAssetId(tags: nil)
            result[assetId] = try await downloader.downloadAsBase64(from: head)
        }
        if let body = character.bodyImageUrl {
            let assetId = CharacterPart.body.getLottieAssetId(tags: nil)
            result[assetId] = try await downloader.downloadAsBase64(from: body)
        }
        if let feet = character.feetImageUrl {
            let assetId = CharacterPart.feet.getLottieAssetId(tags: nil)
            result[assetId] = try await downloader.downloadAsBase64(from: feet)
        }
        return result
    }
    
    func changeItem(json: [String:Any], item: CosmeticItem) async -> [String:Any] {
        let lottieProcessor: LottieImageProcessor = LottieImageProcessor()
        let imageDownloader: ImageDownloader = ImageDownloader()
        do {
            let base64Image = try await imageDownloader.downloadAsBase64(from: item.imageName)
            let replacejson = try lottieProcessor.replaceAsset(
                in: json,
                assetId: item.getAssetId(),
                with: base64Image
            )
            return replacejson
        } catch {
            debugPrint("changeItem실패")
        }
        return json
    }
    
    func changePartItem(json: [String:Any], part: String, assaset: String) async -> [String:Any] {
        let lottieProcessor: LottieImageProcessor = LottieImageProcessor()
        let imageDownloader: ImageDownloader = ImageDownloader()
        do {
            let base64Image = try await imageDownloader.downloadAsBase64(from: assaset)
            let replacejson = try lottieProcessor.replaceAsset(
                in: json,
                assetId: part,
                with: base64Image
            )
            return replacejson
        } catch {
            debugPrint("changeItem실패")
        }
        return json
    }
    
    func removeItem(json: [String:Any], item: CosmeticItem) -> [String:Any] {
        let lottieProcessor: LottieImageProcessor = LottieImageProcessor()
        let replacejson = lottieProcessor.clearAssetImage(in: json, assetId: item.getAssetId())
        return replacejson
    }
    
    func removeAllItem(json: [String:Any]) async -> [String:Any] {
        let lottieProcessor: LottieImageProcessor = LottieImageProcessor()
        let replacejson = lottieProcessor.clearAllAssetImages(in: json)
        headItem = nil
        bodyItem = nil
        feetItem = nil
        return await setDefaultFoot(json: replacejson, grade: character.grade)
    }
    
    func setDefaultFoot(json: [String:Any], grade: String) async -> [String:Any] {
        let lottieProcessor: LottieImageProcessor = LottieImageProcessor()
        var footImage: String = ""
        do {
            if(grade == "SEED") {
                footImage = try assetImageToBase64(named: "DEFAULT_SEED_FEET_IMAGE")
            } else if(grade == "SPROUT") {
                footImage = try assetImageToBase64(named: "DEFAULT_SPROUT_FEET_IMAGE")
            } else if(grade == "TREE") {
                footImage = try assetImageToBase64(named: "DEFAULT_TREE_FEET_IMAGE")
            } else {
                footImage = try assetImageToBase64(named: "DEFAULT_SEED_FEET_IMAGE")
            }
            
            let replacejson = try lottieProcessor.replaceAsset(
                in: json,
                assetId: "foot",
                with: footImage
            )
            return replacejson
        } catch {
            debugPrint("changeItem실패")
        }
        return json
    }
    
    
    func assetImageToBase64(named imageName: String) throws -> String {
        guard let image = UIImage(
            named: imageName,
            in: Bundle.main,   // ⭐️ 중요
            compatibleWith: nil
        ) else {
            throw NSError(domain: "AssetImage", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "이미지를 찾을 수 없음: \(imageName)"
            ])
        }
        
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let renderedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
        
        guard let data = renderedImage.pngData() else {
            throw NSError(domain: "AssetImage", code: 1)
        }
        
        return "data:image/png;base64," + data.base64EncodedString()
    }

}

extension DressingRoomViewModel {
    func categoryStyle(for part: CharacterPart) -> ItemCategoryStyle {
        switch part {
        case .head:
            return ItemCategoryStyle(
                text: "헤어",
                background: Color(hex: "#FFF0F1"),
                foreground: Color(hex: "#F76476")
            )
        case .body:
            return ItemCategoryStyle(
                text: "목도리",
                background: Color(hex: "#F6F4FF"),
                foreground: Color(hex: "#6E5DC6")
            )
        case .feet:
            return ItemCategoryStyle(
                text: "신발",
                background: Color(hex: "#E9F2FF"),
                foreground: Color(hex: "#1D7AFC")
            )
        }
    }
    
    func getGrade(grade: String) -> String {
        switch(grade) {
        case "SEED": return "씨앗"
        case "SPROUT": return "새싹"
        case "TREE": return "나무"
        default: return "씨앗"
        }
    }
    
    func saveItem() {
        let items: [CosmeticItem] = [headItem, bodyItem, feetItem]
            .compactMap{$0}
            .filter{ $0.owned == false }
        
        if(items.isEmpty) {
            let userId = UserManager.shared.userId ?? 0
            if let headImage = headItem?.imageName {
                if(headItem?.tag == "TOP") {
                    UserDefaults.standard.set(headImage, forKey: "\(userId)headTopItem")
                    UserDefaults.standard.removeObject(forKey: "\(userId)headDecorItem")
                } else if(headItem?.tag == "DECOR") {
                    UserDefaults.standard.set(headImage, forKey: "\(userId)headDecorItem")
                    UserDefaults.standard.removeObject(forKey: "\(userId)headTopItem")
                }
            } else {
                UserDefaults.standard.removeObject(forKey: "\(userId)headTopItem")
                UserDefaults.standard.removeObject(forKey: "\(userId)headDecorItem")
            }
            
            if let bodyImage = bodyItem?.imageName {
                UserDefaults.standard.set(bodyImage, forKey: "\(userId)bodyItem")
            } else {
                UserDefaults.standard.removeObject(forKey: "\(userId)bodyItem")
            }
            
            if let feetImage = feetItem?.imageName {
                UserDefaults.standard.set(feetImage, forKey: "\(userId)feetItem")
            } else {
                UserDefaults.standard.removeObject(forKey: "\(userId)feetItem")
            }
            
            wornHeadItem = headItem
            wornBodyItem = bodyItem
            wornFeetItem = feetItem
        } else {
            canBuyItem = (items.reduce(0) { $0 + $1.point} <= point)
            isShowBuy = true
        }
    }
    
    func buyItems() async {
        let items: [CosmeticItem] = [headItem, bodyItem, feetItem]
            .compactMap{$0}
            .filter{ $0.owned == false }

        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            try await serverManager.postItems(token: accessToken, items: items)
            await fetchItems()
        } catch {
            debugPrint("postItems 실패")
        }
    }
    
    func isWearingItem(item: CosmeticItem) -> Bool {
        return (headItem == item) || (bodyItem == item) || (feetItem == item)
    }
    
    func isChangedItem() -> Bool {
        if(wornHeadItem != headItem) { return true }
        if(wornBodyItem != bodyItem) { return true }
        if(wornFeetItem != feetItem) { return true }
        return false
    }
}

struct ItemCategoryStyle {
    let text: String
    let background: Color
    let foreground: Color
}
