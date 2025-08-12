import Foundation

struct Diary: Codable, Equatable, Identifiable {
    var id: String = .init()  // 저장소에서 관리
    var user: User = .init()
    var emotion: Emotion = .init()
    var title: String = .init()
    var body: String = .init()
    var views: Int = .init()  // 저장소에서 관리
    var occurredAt: Date = .init()
    var createdAt: Date = .init()  // 저장소에서 관리
    var updatedAt: Date = .init()  // 저장소에서 관리
    var latitude: Double = .init()
    var longitude: Double = .init()
    var place: String = .init()
    var shared: Bool = .init()
    var deleted: Bool = .init()  // 저장소에서 관리
}
