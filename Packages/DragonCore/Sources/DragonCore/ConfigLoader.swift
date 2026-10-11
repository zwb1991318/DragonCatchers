import Foundation

public enum ConfigError: Error, Equatable {
    case missingResource(String)
    case unknownDragonKind(String)
}

public enum ConfigLoader {
    public static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try JSONDecoder().decode(type, from: data)
    }

    /// 读取包里自带的 Data/<name>.json
    public static func bundled<T: Decodable>(_ type: T.Type, named name: String) throws -> T {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw ConfigError.missingResource(name)
        }
        return try decode(type, from: Data(contentsOf: url))
    }

    /// 检查关卡里用到的龙种类是否都在数值配置里
    public static func validate(level: LevelConfig, against balance: BalanceConfig) throws {
        for wave in level.waves {
            for group in wave.groups where balance.dragons[group.kind] == nil {
                throw ConfigError.unknownDragonKind(group.kind)
            }
        }
    }
}
