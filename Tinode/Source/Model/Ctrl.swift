// Please help improve quicktype by enabling anonymous telemetry with:
//
//   $ quicktype --telemetry enable
//
// You can also enable telemetry on any quicktype invocation:
//
//   $ quicktype pokedex.json -o Pokedex.cs --telemetry enable
//
// This helps us improve quicktype by measuring:
//
//   * How many people use quicktype
//   * Which features are popular or unpopular
//   * Performance
//   * Errors
//
// quicktype does not collect:
//
//   * Your filenames or input data
//   * Any personally identifiable information (PII)
//   * Anything not directly related to quicktype's usage
//
// If you don't want to help improve quicktype, you can dismiss this message with:
//
//   $ quicktype --telemetry disable
//
// For a full privacy policy, visit app.quicktype.io/privacy
//

import Foundation

struct Ctrl: Codable {
    let id: String
    let code: Int
    let text, ts: String
    var params: Dictionary<String, Any>?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StaticCodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.code = try container.decode(Int.self, forKey: .code)
        self.text = try container.decode(String.self, forKey: .text)
        self.ts = try container.decode(String.self, forKey: .ts)
        do {
            self.params = try Ctrl.decodeParams(from: container.superDecoder(forKey: .params))
        } catch {
            
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StaticCodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.code, forKey: .code)
        try container.encode(self.text, forKey: .text)
        try container.encode(self.ts, forKey: .ts)
        try encodeParams(to: container.superEncoder(forKey: .params))
    }
    
    static func decodeParams(from decoder: Decoder) throws -> [String: Any] {
        
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var result: [String: Any] = [:]
        for key in container.allKeys {
            if let double = try? container.decode(Double.self, forKey: key) {
                result[key.stringValue] = double
            } else if let string = try? container.decode(String.self, forKey: key) {
                result[key.stringValue] = string
            }
        }
        return result
    }
    
    func encodeParams(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKeys.self)
        if let ps = params {
            for (key, value) in ps {
                switch value {
                case let double as Double:
                    try container.encode(double, forKey: DynamicCodingKeys(stringValue: key)!)
                case let string as String:
                    try container.encode(string, forKey: DynamicCodingKeys(stringValue: key)!)
                default:
                    fatalError("unexpected type")
                }
            }
        }
    }
    
    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int?
        
        init?(intValue: Int) {
            self.init(stringValue: "")
            self.intValue = intValue
        }
        
    }
    
    private enum StaticCodingKeys: String, CodingKey {
        case id, code, text, ts, params
    }
    
}


