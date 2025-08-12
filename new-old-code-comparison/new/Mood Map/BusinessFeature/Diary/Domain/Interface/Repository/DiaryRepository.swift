import Foundation

protocol DiaryRepository {
    // Create
    func createDiary(_ diary: Diary) async throws -> Diary
    func restoreDiaries(userId: Int) async throws

    // Read
    func readDiary(uuid: String) -> Diary?
    func readDiariesForList(date: Date) -> [Diary]
    func readDiariesForCalendar(date: Date) -> [Diary]
    func readDiariesForStatistics() -> [Diary]
    func readSharedDiary(uuid: String) async throws -> Diary
    func readSharedDiaries(latitude: Double, longitude: Double, range: Double) async throws -> [Diary]

    // Update
    func updateDiary(_ diary: Diary) async throws -> Diary

    // Delete
    func deleteDiary(_ diary: Diary) async throws
    func deleteDiaries() async throws -> Bool
    func deleteLocalDiaries() -> Bool
}
