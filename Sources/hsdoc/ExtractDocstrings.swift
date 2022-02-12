import ArgumentParser
import Files
import Foundation
import HSDocKit

let supportedExtensions: Set = ["m", "lua"]

enum ExtractionError: Error {
    case message(String)
}

extension ExtractionError: CustomStringConvertible {
    var description: String {
        switch self {
        case .message(let message):
            return message
        }
    }
}

@main
struct ExtractDocstrings: ParsableCommand {
    @Argument(help: "Directories to search for code files")
    var searchDirs: [String] = []
    
    @Flag
    var verbose: Bool = false

    mutating func run() throws {
        guard !searchDirs.isEmpty else {
            fail("Provide one or more directories to search in.")
        }
        
        print("Looking for code in: \(searchDirs)")

        let parsedDocs = parseFiles(in: searchDirs)
        let output = processDocs(in: parsedDocs)
    }
    
    func parseFiles(in directories: [String]) -> [String:Docs] {
        var docs = [String:Docs]()
        for searchDir in directories {
            debug("Searching: \(searchDir)")
            
            let folder: Folder
            do {
                folder = try Folder(path: searchDir)
            } catch {
                err("Unable to access '\(searchDir)' as a folder: \(error)")
                continue
            }
            
            for file in folder.files.recursive {
                if let ext = file.extension, supportedExtensions.contains(ext) {
                    parseDocs(from: file, into: &docs)
                }
            }
        }
        
        return docs
    }
    
    func parseDocs(from file: File, into docs: inout [String:Docs]) {
        do {
            info("Parsing: \(file.path)")
            let fileContents = try file.readAsString()
            var text = TextDocument(content: fileContents)
            let fileDocs = try Docs.parser.parse(&text)
            debug("Parsed:\n\(fileDocs)")
            if !fileDocs.isEmpty {
                docs[file.path] = fileDocs
            }
            info("Parsed: \(file.path)")
        } catch {
            err("Unable to parse file '\(file.path)': \(error)")
        }
    }
    
    func processDocs(in: [String:Docs]) -> Any {
        true
    }
    
    // Utility functions
    func debug(_ message: @autoclosure () -> String) {
    #if DEBUG
        print("DEBUG: \(message())")
    #endif
    }
    
    func info(_ message: @autoclosure () -> String) {
        if verbose {
            print("INFO: \(message())")
        }
    }

    func warn(_ message: @autoclosure () -> String) {
        if verbose {
            print("WARNING: \(message())")
        }
    }

    func err(_ message: String) {
        print("ERROR: \(message)")
    }
    
    func fail(_ message: String) -> Never {
        Self.exit(withError: ExtractionError.message(message))
    }
}
