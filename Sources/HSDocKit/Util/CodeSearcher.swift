import Foundation

//func parseDocs(path: String) -> Docs? {
//    guard let reader = LineReader<Substring>(path: path) else {
//        return nil
//    }
//    
//    var docs = Docs()
//    var parser = Docs.parser()
//    
//    var lines = [Line<Substring>]()[...]
//    var count = 0
//    
//    for line in reader {
//        count = count + 1
//        lines.append(.init(number: 1, text: line))
//        
//        if let doc = parser.parse(&lines) {
//            docs.append(doc)
//        }
//    }
//    
//    return docs
//}

