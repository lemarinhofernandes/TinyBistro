import Foundation

struct GridPosition: Hashable, Sendable {
    var column: Int
    var row: Int

    func movedToward(_ destination: GridPosition) -> GridPosition {
        if column != destination.column {
            return GridPosition(column: column + (destination.column > column ? 1 : -1), row: row)
        }

        if row != destination.row {
            return GridPosition(column: column, row: row + (destination.row > row ? 1 : -1))
        }

        return self
    }
}

struct GridSize: Hashable, Sendable {
    var columns: Int
    var rows: Int

    func contains(_ position: GridPosition) -> Bool {
        position.column >= 0 &&
        position.row >= 0 &&
        position.column < columns &&
        position.row < rows
    }
}
