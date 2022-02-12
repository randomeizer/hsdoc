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
struct Hsdoc: ParsableCommand {
    @Argument(help: "Directories to search for code files.")
    var searchDirs: [String] = []
    
    @Option(name: .shortAndLong, help: "The output filename.")
    var output: String
    
    @Flag(help: "Output additional details while processing.")
    var noisy: Bool = false
    
    @Flag(help: "Output debugging information while processing.")
    var debug: Bool = false

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
            info("Searching: \(searchDir)")
            
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
    
    func processDocs(in parsedDocs: [String:Docs]) -> [Module] {
        var moduleSet = [ModuleSignature:Module]()
        var modules = [Module]()
        
        for (filename, docs) in parsedDocs {
            for docBlock in docs {
                switch docBlock.doc {
                case let .module(name: name, description: _):
                    if moduleSet[name] != nil {
                        err("Duplicate module defined in '\(filename)': \(name)")
                    } else {
                        guard let module = Module(doc: docBlock.doc) else {
                            err("Unexpected error occurred while initialising a module.")
                            break
                        }
                        moduleSet[name] = module
                        modules.append(module)
                    }
                case .item(let item):
                    #warning("unimplemented")
                    break
                }
            }
        }
        
        return modules
    }
    
    /// Outputs the message if `debug` is `true`
    ///
    /// - Parameter message: The message to output.
    func debug(_ message: @autoclosure () -> String) {
        if debug {
            print("DEBUG: \(message())")
        }
    }
    
    /// Outputs the message if `verbose` is `true`.
    ///
    /// - Parameter message: The message to output.
    func info(_ message: @autoclosure () -> String) {
        if noisy {
            print("INFO: \(message())")
        }
    }

    /// Outputs the message as a `"WARNING"`.
    ///
    /// - Parameter message: The message to output.
    func warn(_ message: String) {
        print("WARNING: \(message)")
    }

    /// Outputs the message as an `"ERROR"`.
    ///
    /// - Parameter message: The message to output.
    func err(_ message: String) {
        var stdErr = StandardErrorOutputStream()
        print("ERROR: \(message)", to: &stdErr)
    }
    
    /// Fails, terminating the execution, and outputting the message.
    ///
    /// - Parameter message: The message to output.
    func fail(_ message: String) -> Never {
        Self.exit(withError: ExtractionError.message(message))
    }
}
