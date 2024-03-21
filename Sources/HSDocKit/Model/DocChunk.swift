import NonEmpty

/// Represents a chunk of documentation - that is, a series of lines beginning with either `---` (lua) or `///` (obj-c).
public struct DocChunk: Equatable {
    let lines: NonEmpty<[TextLine]>
}
