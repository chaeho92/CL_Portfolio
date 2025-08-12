class DefaultEmotionRepository: EmotionRepository {

    let localEmotionService: LocalEmotionService
    let emotionService: EmotionService

    init(
        localEmotionService: LocalEmotionService = DefaultLocalEmotionService(),
        emotionService: EmotionService = DefaultEmotionService()
    ) {
        self.localEmotionService = localEmotionService
        self.emotionService = emotionService
    }

    func updateEmotions() async throws -> [Emotion] {
        return try await emotionService.readEmotions().map {
            self.localEmotionService.createEmotions($0)

            return $0
        }.asyncValue()
    }

    func readEmotionsSortedByAsc() -> [Emotion] {
        localEmotionService.readAllEmotion().map { $0.toModel() }.sorted(by: { $0.id < $1.id })
    }

}
