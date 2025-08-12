import RealmSwift

class EmotionObject: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var info: String
}

extension EmotionObject {
    // Realm Object에서 일반 모델 변환
    func toModel() -> Emotion {
        return Emotion(id: self.id, name: self.name, description: self.info)
    }
}
