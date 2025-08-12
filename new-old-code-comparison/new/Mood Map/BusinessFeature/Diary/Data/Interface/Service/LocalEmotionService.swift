protocol LocalEmotionService {
    func createEmotions(_ emotions: [Emotion])
    func readEmotion(id: Int) -> EmotionObject?
    func readAllEmotion() -> [EmotionObject]
    func deleteEmotion(emotionObject: EmotionObject)
    func deleteAllEmotion()
}
