import Foundation
import Combine

class GoalsManagerViewModel: ObservableObject {
    private let serverManager = ServerManager.shared
    
    @Published var targetWalkCount: Int = 1
    @Published var targetStepCount: Int = 1_000
    @Published var isEditEanble: Bool = true
    let lastEventMonthKey = "lastEventMonth"
    let weeklyRange = 1...7
    let stepsRange = 1_000...30_000
    
    let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f
    }()
    
    func getGoals() async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            let goals = try await serverManager.getGoals(token: accessToken)
            targetStepCount = goals.targetStepCount
            targetWalkCount = goals.targetWalkCount
        } catch {
            debugPrint("getGoals Error")
        }
    }
    
    func putGoals() async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            try await serverManager.putGoals(token: accessToken, goals: Goals(targetStepCount: targetStepCount, targetWalkCount: targetWalkCount))
            UserManager.shared.targetStepCount = targetStepCount
            UserManager.shared.targetWalkCount = targetWalkCount
            saveCurrentMonth()
        } catch {
            isEditEanble = false
            debugPrint("putGoals Error")
        }
    }
    
    func saveCurrentMonth() {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: now)
        
        if let year = components.year, let month = components.month {
            let monthString = "\(year)-\(month)"
            UserDefaults.standard.set(monthString, forKey: lastEventMonthKey)
        }
    }
    
    func isSameMonthRecorded() -> Bool {
        guard let lastMonth = UserDefaults.standard.string(forKey: lastEventMonthKey) else { return false }
        
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: now)
        
        if let year = components.year, let month = components.month {
            let currentMonth = "\(year)-\(month)"
            return lastMonth == currentMonth
        }
        
        return false
    }
}
