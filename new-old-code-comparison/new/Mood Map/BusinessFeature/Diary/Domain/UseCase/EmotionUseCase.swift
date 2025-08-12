import Foundation

class EmotionUseCase {

    let emotionRepository: EmotionRepository

    init(emotionRepository: EmotionRepository = DefaultEmotionRepository()) {
        self.emotionRepository = emotionRepository
    }

    func updateEmotions() async throws -> [Emotion] {
        return try await emotionRepository.updateEmotions()
    }

    func readEmotionsSortedByAsc() -> [Emotion] {
        return emotionRepository.readEmotionsSortedByAsc()
    }

}
