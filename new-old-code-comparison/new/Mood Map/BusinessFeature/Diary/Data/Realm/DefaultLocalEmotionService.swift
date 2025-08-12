class DefaultLocalEmotionService: RealmConnector, LocalEmotionService {
    let LOGGER = LoggerProvider.shared.getLogger(classType: DefaultLocalEmotionService.self)

    func createEmotions(_ emotions: [Emotion]) {
        emotions.forEach { emotion in
            do {
                let emotionObject = EmotionObject()
                emotionObject.id = emotion.id
                emotionObject.name = emotion.name
                emotionObject.info = emotion.description

                try realm?.write {
                    realm?.add(emotionObject, update: .modified)
                }
            } catch {
                LOGGER.errorLog("Failed to create emotions. Cause: \(error)")
            }
        }
    }

    func readEmotion(id: Int) -> EmotionObject? {
        return realm?.object(ofType: EmotionObject.self, forPrimaryKey: id)
    }

    func readAllEmotion() -> [EmotionObject] {
        return realm.flatMap { Array($0.objects(EmotionObject.self)) } ?? []
    }

    func deleteEmotion(emotionObject: EmotionObject) {
        do {
            try realm?.write {
                realm?.delete(emotionObject)
            }
        } catch {
            LOGGER.errorLog("Failed to delete emotion. Cause: \(error)")
        }
    }

    func deleteAllEmotion() {
        readAllEmotion().forEach { item in
            do {
                try realm?.write {
                    realm?.delete(item)
                }
            } catch {
                LOGGER.errorLog("Failed to delete emotions. Cause: \(error)")
            }
        }
    }
}
