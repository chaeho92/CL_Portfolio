protocol EmotionRepository {
    func updateEmotions() async throws -> [Emotion]
    func readEmotionsSortedByAsc() -> [Emotion]
}
