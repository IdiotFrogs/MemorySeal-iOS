import Foundation

struct JoinTicketResponseDTO: Decodable {
    let id: Int?
    let capsuleId: Int?
    let timeCapsuleId: Int?

    var toDomain: Int? {
        return timeCapsuleId ?? capsuleId ?? id
    }
}
