//
//  GTFSZipReader.swift
//  Island Base
//
//  GTFS（ZIP）から .txt ファイルを取り出す
//

import Foundation
import zlib

enum GTFSZipReader {
    static func extractTextFiles(from zipData: Data) throws -> [String: String] {
        var files: [String: String] = [:]
        var offset = 0
        let bytes = [UInt8](zipData)

        while offset + 30 <= bytes.count {
            let signature = readUInt32(bytes, offset)
            guard signature == 0x0403_4b50 else { break }

            let compressionMethod = readUInt16(bytes, offset + 8)
            let compressedSize = Int(readUInt32(bytes, offset + 18))
            let uncompressedSize = Int(readUInt32(bytes, offset + 22))
            let fileNameLength = Int(readUInt16(bytes, offset + 26))
            let extraFieldLength = Int(readUInt16(bytes, offset + 28))

            let nameStart = offset + 30
            let nameEnd = nameStart + fileNameLength
            guard nameEnd <= bytes.count else { break }

            let fileName = String(bytes: bytes[nameStart..<nameEnd], encoding: .utf8) ?? ""
            let dataStart = nameEnd + extraFieldLength
            let dataEnd = dataStart + compressedSize
            guard dataEnd <= bytes.count else { break }

            if fileName.hasSuffix(".txt") {
                let compressed = Data(bytes[dataStart..<dataEnd])
                let fileData: Data

                switch compressionMethod {
                case 0:
                    fileData = compressed
                case 8:
                    guard let inflated = inflateDeflate(compressed, expectedSize: uncompressedSize) else {
                        throw GTFSZipReaderError.decompressionFailed(fileName)
                    }
                    fileData = inflated
                default:
                    throw GTFSZipReaderError.unsupportedCompression(fileName)
                }

                if let text = String(data: fileData, encoding: .utf8) {
                    files[fileName] = text
                }
            }

            offset = dataEnd
        }

        guard files.isEmpty == false else {
            throw GTFSZipReaderError.emptyArchive
        }

        return files
    }

    private static func readUInt16(_ bytes: [UInt8], _ offset: Int) -> UInt16 {
        UInt16(bytes[offset]) | (UInt16(bytes[offset + 1]) << 8)
    }

    private static func readUInt32(_ bytes: [UInt8], _ offset: Int) -> UInt32 {
        UInt32(bytes[offset])
            | (UInt32(bytes[offset + 1]) << 8)
            | (UInt32(bytes[offset + 2]) << 16)
            | (UInt32(bytes[offset + 3]) << 24)
    }

    private static func inflateDeflate(_ data: Data, expectedSize: Int) -> Data? {
        guard expectedSize > 0 else { return Data() }

        var output = Data(count: expectedSize)
        let result: Int32 = data.withUnsafeBytes { inputBuffer in
            output.withUnsafeMutableBytes { outputBuffer in
                guard let inputPointer = inputBuffer.bindMemory(to: Bytef.self).baseAddress,
                      let outputPointer = outputBuffer.bindMemory(to: Bytef.self).baseAddress else {
                    return Z_STREAM_ERROR
                }

                var stream = z_stream()
                stream.next_in = UnsafeMutablePointer<Bytef>(mutating: inputPointer)
                stream.avail_in = uInt(data.count)
                stream.next_out = outputPointer
                stream.avail_out = uInt(expectedSize)

                let initResult = inflateInit2_(&stream, -MAX_WBITS, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
                guard initResult == Z_OK else { return initResult }

                let inflateResult = inflate(&stream, Z_FINISH)
                inflateEnd(&stream)
                return inflateResult
            }
        }

        guard result == Z_STREAM_END else { return nil }
        return output
    }
}

enum GTFSZipReaderError: Error {
    case emptyArchive
    case decompressionFailed(String)
    case unsupportedCompression(String)
}
