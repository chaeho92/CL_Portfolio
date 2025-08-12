import Foundation

class DefaultLocalDiaryService: RealmConnector, LocalDiaryService {
    let LOGGER = LoggerProvider.shared.getLogger(classType: DefaultLocalDiaryService.self)

    func createDiary(_ diaryObject: DiaryObject) {
        do {
            try realm?.write {
                realm?.add(diaryObject, update: .modified)
            }
        } catch {
            LOGGER.errorLog("Failed to create diary. Cause: \(error)")
        }
    }

    func readDiary(uuid id: String) -> DiaryObject? {  // UUID 기준 조회
        return realm?.object(ofType: DiaryObject.self, forPrimaryKey: id)
    }

    func readDiariesByDay(date: Date) -> [DiaryObject] {  // 일 기준 조회
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        return realm.flatMap {
            Array($0.objects(DiaryObject.self).filter("occurredAt >= %@ AND occurredAt < %@", startDate, endDate))
        } ?? []
    }

    func readDiariesByMonth(date: Date) -> [DiaryObject] {  // 월 기준 조회
        let calendar = Calendar.current
        let startDate = calendar.date(
            from: DateComponents(
                year: calendar.component(.year, from: date),
                month: calendar.component(.month, from: date),
                day: 1
            ))!
        let endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
        return realm.flatMap {
            Array($0.objects(DiaryObject.self).filter("occurredAt >= %@ AND occurredAt < %@", startDate, endDate))
        } ?? []
    }

    func readDiariesByYear(date: Date) -> [DiaryObject] {  // 연 기준 조회
        let calendar = Calendar.current
        let startDate = calendar.date(
            from: DateComponents(
                year: calendar.component(.year, from: date),
                month: 1,
                day: 1
            ))!
        let endDate = calendar.date(byAdding: .year, value: 1, to: startDate)!
        return realm.flatMap {
            Array($0.objects(DiaryObject.self).filter("occurredAt >= %@ AND occurredAt < %@", startDate, endDate))
        } ?? []
    }

    func readAllDiary() -> [DiaryObject] {
        guard let realm = realm else { return [] }
        return Array(realm.objects(DiaryObject.self))
    }

    func updateDiary(_ diary: Diary) -> DiaryObject? {
        guard let diaryObject = readDiary(uuid: diary.id) else { return nil }

        do {
            try realm?.write {
                diaryObject.emotion = realm?.object(ofType: EmotionObject.self, forPrimaryKey: diary.emotion.id)
                diaryObject.title = diary.title
                diaryObject.body = diary.body
                diaryObject.occurredAt = diary.occurredAt
                diaryObject.updatedAt = diary.updatedAt
                diaryObject.latitude = diary.latitude
                diaryObject.longitude = diary.longitude
                diaryObject.place = diary.place
                diaryObject.shared = diary.shared
            }
        } catch {
            LOGGER.errorLog("Failed to update diary. Cause: \(error)")
        }

        return diaryObject
    }

    func deleteDiaries(diaryObjects: [DiaryObject]) {
        do {
            if diaryObjects.isEmpty { return }

            try realm?.write {
                realm?.delete(diaryObjects)
            }
        } catch {
            LOGGER.errorLog("Failed to delete diaries Cause: \(error)")
        }
    }

    func increaseViews(diaryObject: DiaryObject) {  // 일기 열람 시 조회수 증가
        do {
            try realm?.write {
                diaryObject.views += 1
            }
        } catch {
            LOGGER.errorLog("Failed to increase views. Cause: \(error)")
        }
    }
}
