import RealmSwift

class DiaryObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var userId: Int
    @Persisted var emotion: EmotionObject?  // Object property 'emotion' must be marked as optional. (RLMException)
    @Persisted var title: String
    @Persisted var body: String
    @Persisted var views: Int  // 일기 상세에 표시될 때 ++
    @Persisted var occurredAt: Date
    @Persisted var createdAt: Date
    @Persisted var updatedAt: Date  // 일기 편집 시 업데이트
    @Persisted var latitude: Double
    @Persisted var longitude: Double
    @Persisted var place: String
    @Persisted var shared: Bool
    @Persisted var deleted: Bool
}

extension DiaryObject {
    // Realm Object에서 일반 모델 변환
    func toModel() -> Diary {
        return Diary(
            id: self.id,
            user: User(id: self.userId),
            emotion: self.emotion!.toModel(),
            title: self.title,
            body: self.body,
            views: self.views,
            occurredAt: self.occurredAt,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            latitude: self.latitude,
            longitude: self.longitude,
            place: self.place,
            shared: self.shared,
            deleted: self.deleted
        )
    }

    func toModelOnlyEmotionAndOccurredAt() -> Diary {
        return Diary(
            id: self.id,
            user: User(id: self.userId),
            emotion: self.emotion!.toModel(),
            occurredAt: self.occurredAt
        )
    }
}
