import Foundation

class ProcessRunner {
    func run(command: String, arguments: [String], timeout: TimeInterval = 60, completion: @escaping (String, String?) -> Void) {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [command] + arguments
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        // Set up environment to find mempalace (GUI apps have limited PATH)
        let extendedPath = "/opt/homebrew/Caskroom/miniforge/base/bin:/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        var env = ProcessInfo.processInfo.environment
        if let path = env["PATH"] {
            env["PATH"] = extendedPath + ":" + path
        } else {
            env["PATH"] = extendedPath
        }
        process.environment = env

        do {
            try process.run()
        } catch {
            completion("", "Failed to run command: \(error.localizedDescription)")
            return
        }

        DispatchQueue.global().async {
            process.waitUntilExit()

            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

            let output = String(data: outputData, encoding: .utf8) ?? ""
            let errorOutput = String(data: errorData, encoding: .utf8)

            DispatchQueue.main.async {
                completion(output, errorOutput?.isEmpty == true ? nil : errorOutput)
            }
        }
    }

    func runSync(command: String, arguments: [String], timeout: TimeInterval = 60) -> (output: String, error: String?) {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [command] + arguments
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        var env = ProcessInfo.processInfo.environment
        let extendedPath = "/opt/homebrew/Caskroom/miniforge/base/bin:/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        if let path = env["PATH"] {
            env["PATH"] = extendedPath + ":" + path
        } else {
            env["PATH"] = extendedPath
        }
        process.environment = env

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return ("", "Failed to run command: \(error.localizedDescription)")
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        let output = String(data: outputData, encoding: .utf8) ?? ""
        let errorOutput = String(data: errorData, encoding: .utf8)

        return (output, errorOutput?.isEmpty == true ? nil : errorOutput)
    }
}
