enum MediaProgressStatus: String, Sendable {
    case planned = "PLANNED"
    case inProgress = "IN_PROGRESS"
    case completed = "COMPLETED"
    case paused = "PAUSED"
    case dropped = "DROPPED"
}
