import Foundation
import UIKit

struct CommandParser {
    let fileSystem = FakeFileSystem.shared

    func execute(_ input: String, cwd: String) -> CommandResult {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return CommandResult(output: "", newCwd: cwd) }

        // Handle pipe (simple: just show output of first command)
        if trimmed.contains(" | ") {
            let parts = trimmed.components(separatedBy: " | ")
            let first = execute(parts[0], cwd: cwd)
            return CommandResult(output: first.output, newCwd: first.newCwd)
        }

        let parts = trimmed.components(separatedBy: " ").filter { !$0.isEmpty }
        guard let command = parts.first else { return CommandResult(output: "", newCwd: cwd) }
        let args = Array(parts.dropFirst())

        switch command {
        // File system
        case "ls": return CommandResult(output: listFiles(cwd, args: args), newCwd: cwd)
        case "cd": return changeDirectory(args, cwd: cwd)
        case "pwd": return CommandResult(output: cwd, newCwd: cwd)
        case "cat": return CommandResult(output: catFile(args, cwd: cwd), newCwd: cwd)
        case "head": return CommandResult(output: catFile(args, cwd: cwd), newCwd: cwd)
        case "tail": return CommandResult(output: catFile(args, cwd: cwd), newCwd: cwd)
        case "wc": return CommandResult(output: "      42     256    1847", newCwd: cwd)
        case "file": return CommandResult(output: "\(args.first ?? ""): ASCII text", newCwd: cwd)
        case "find": return CommandResult(output: findFiles(args, cwd: cwd), newCwd: cwd)
        case "which": return CommandResult(output: whichCommand(args), newCwd: cwd)
        case "tree": return CommandResult(output: treeOutput(cwd), newCwd: cwd)

        // System info
        case "whoami": return CommandResult(output: "admin", newCwd: cwd)
        case "hostname": return CommandResult(output: UIDevice.current.name, newCwd: cwd)
        case "uname": return CommandResult(output: unameOutput(args), newCwd: cwd)
        case "uptime": return CommandResult(output: uptimeOutput, newCwd: cwd)
        case "id": return CommandResult(output: "uid=501(admin) gid=20(staff) groups=20(staff),12(everyone),61(localaccounts)", newCwd: cwd)
        case "sw_vers": return CommandResult(output: swVersOutput, newCwd: cwd)
        case "sysctl": return CommandResult(output: sysctlOutput, newCwd: cwd)
        case "top": return CommandResult(output: topOutput, newCwd: cwd)
        case "ps": return CommandResult(output: psOutput, newCwd: cwd)
        case "df": return CommandResult(output: dfOutput, newCwd: cwd)
        case "free", "vm_stat": return CommandResult(output: memoryOutput, newCwd: cwd)
        case "env": return CommandResult(output: envOutput, newCwd: cwd)
        case "printenv": return CommandResult(output: envOutput, newCwd: cwd)

        // Text/output
        case "echo": return CommandResult(output: echoCommand(args), newCwd: cwd)
        case "printf": return CommandResult(output: args.joined(separator: " "), newCwd: cwd)
        case "date": return CommandResult(output: dateOutput(args), newCwd: cwd)
        case "cal": return CommandResult(output: calOutput, newCwd: cwd)

        // Network
        case "ifconfig": return CommandResult(output: ifconfigOutput, newCwd: cwd)
        case "ping": return CommandResult(output: pingOutput(args), newCwd: cwd)
        case "curl": return CommandResult(output: "curl: (6) Could not resolve host", newCwd: cwd)
        case "wget": return CommandResult(output: "zsh: command not found: wget\nTry: brew install wget", newCwd: cwd)
        case "ssh": return CommandResult(output: "ssh: connect to host \(args.first ?? "localhost") port 22: Connection refused", newCwd: cwd)
        case "nslookup", "dig": return CommandResult(output: "Server: 8.8.8.8\nAddress: 8.8.8.8#53\n\nNon-authoritative answer:\nName: \(args.first ?? "example.com")\nAddress: 93.184.216.34", newCwd: cwd)

        // Package managers
        case "brew": return CommandResult(output: brewOutput(args), newCwd: cwd)
        case "pip", "pip3": return CommandResult(output: "pip 24.0 from /usr/local/lib/python3.12/site-packages/pip", newCwd: cwd)
        case "npm": return CommandResult(output: "10.2.4", newCwd: cwd)
        case "node": return CommandResult(output: args.contains("-v") ? "v21.6.1" : "Welcome to Node.js v21.6.1.\nType \".help\" for more information.\n> ", newCwd: cwd)
        case "python", "python3": return CommandResult(output: "Python 3.12.2", newCwd: cwd)
        case "ruby": return CommandResult(output: "ruby 3.3.0 (2024-12-25 revision abc123) [arm64-darwin24]", newCwd: cwd)
        case "swift": return CommandResult(output: "Swift version 6.0 (swift-6.0-RELEASE)\nTarget: arm64-apple-macosx15.0", newCwd: cwd)
        case "git": return CommandResult(output: gitOutput(args), newCwd: cwd)
        case "xcode-select": return CommandResult(output: "/Applications/Xcode.app/Contents/Developer", newCwd: cwd)

        // Dev tools
        case "vim", "nano", "vi": return CommandResult(output: "macfake: \(command): interactive editors not supported", newCwd: cwd)
        case "man": return CommandResult(output: manOutput(args), newCwd: cwd)
        case "grep": return CommandResult(output: "Usage: grep [OPTION]... PATTERN [FILE]...", newCwd: cwd)
        case "sed", "awk": return CommandResult(output: "macfake: \(command): not implemented in simulator", newCwd: cwd)
        case "xcodebuild": return CommandResult(output: "Xcode 16.0\nBuild version 16A242d", newCwd: cwd)

        // Fun
        case "neofetch": return CommandResult(output: neofetchOutput, newCwd: cwd)
        case "cowsay": return CommandResult(output: cowsay(args.joined(separator: " ")), newCwd: cwd)
        case "fortune": return CommandResult(output: fortune, newCwd: cwd)
        case "sl": return CommandResult(output: "🚂💨 choo choo!", newCwd: cwd)
        case "say": return CommandResult(output: "macfake: speakers not available", newCwd: cwd)
        case "open": return CommandResult(output: "macfake: open: not supported in simulator", newCwd: cwd)
        case "screenfetch": return CommandResult(output: neofetchOutput, newCwd: cwd)

        // System
        case "clear": return CommandResult(output: "__CLEAR__", newCwd: cwd)
        case "history": return CommandResult(output: "    1  ls\n    2  cd Documents\n    3  pwd\n    4  neofetch", newCwd: cwd)
        case "alias": return CommandResult(output: "alias ll='ls -la'\nalias ..='cd ..'\nalias gs='git status'", newCwd: cwd)
        case "export": return CommandResult(output: "", newCwd: cwd)
        case "source": return CommandResult(output: "", newCwd: cwd)
        case "help": return CommandResult(output: helpText, newCwd: cwd)
        case "exit", "logout": return CommandResult(output: "logout\n[Process completed]", newCwd: cwd)

        // Write operations
        case "mkdir", "touch", "rm", "cp", "mv", "chmod", "chown", "ln":
            return CommandResult(output: "macfake: \(command): read-only file system", newCwd: cwd)
        case "sudo":
            return CommandResult(output: "Password: ********\nadmin is not in the sudoers file. This incident will be reported. 😏", newCwd: cwd)
        case "su":
            return CommandResult(output: "su: Sorry", newCwd: cwd)

        default:
            return CommandResult(output: "zsh: command not found: \(command)", newCwd: cwd)
        }
    }

    // MARK: - File Commands

    private func listFiles(_ cwd: String, args: [String]) -> String {
        let node = resolveNode(cwd)
        guard let children = node?.children else { return "" }
        let showHidden = args.contains("-a") || args.contains("-la") || args.contains("-al")
        let longFormat = args.contains("-l") || args.contains("-la") || args.contains("-al")

        var items = children
        if showHidden {
            items = [FakeNode.folder(".", children: []), FakeNode.folder("..", children: [])] + items
        }

        if longFormat {
            var lines = ["total \(items.count * 8)"]
            for item in items {
                let perms = item.isFolder ? "drwxr-xr-x" : "-rw-r--r--"
                let size = String(format: "%6d", item.fileSize ?? 4096)
                let date = formatDate(item.modifiedDate)
                lines.append("\(perms)  1 admin  staff  \(size) \(date) \(item.name)")
            }
            return lines.joined(separator: "\n")
        }
        return items.map { $0.name }.joined(separator: "\n")
    }

    private func changeDirectory(_ args: [String], cwd: String) -> CommandResult {
        guard let target = args.first else {
            return CommandResult(output: "", newCwd: "/Users/admin")
        }
        if target == ".." {
            let parts = cwd.components(separatedBy: "/").filter { !$0.isEmpty }
            if parts.count <= 1 { return CommandResult(output: "", newCwd: "/") }
            return CommandResult(output: "", newCwd: "/" + parts.dropLast().joined(separator: "/"))
        }
        if target == "~" || target == "$HOME" {
            return CommandResult(output: "", newCwd: "/Users/admin")
        }
        if target == "/" { return CommandResult(output: "", newCwd: "/") }
        if target == "-" { return CommandResult(output: cwd, newCwd: cwd) }

        let newPath = target.hasPrefix("/") ? target : cwd + "/" + target
        if resolveNode(newPath)?.isFolder == true {
            return CommandResult(output: "", newCwd: newPath)
        }
        return CommandResult(output: "cd: no such file or directory: \(target)", newCwd: cwd)
    }

    private func catFile(_ args: [String], cwd: String) -> String {
        guard let filename = args.first else { return "cat: missing operand" }
        let path = filename.hasPrefix("/") ? filename : cwd + "/" + filename
        if let node = resolveNode(path), !node.isFolder {
            return "[contents of \(node.name) — \(node.formattedSize)]"
        }
        return "cat: \(filename): No such file or directory"
    }

    private func findFiles(_ args: [String], cwd: String) -> String {
        guard let node = resolveNode(cwd), let children = node.children else { return "" }
        return children.map { "\(cwd)/\($0.name)" }.joined(separator: "\n")
    }

    private func whichCommand(_ args: [String]) -> String {
        guard let cmd = args.first else { return "which: missing argument" }
        let known = ["ls", "cd", "pwd", "cat", "echo", "git", "python3", "node", "brew", "swift", "ruby"]
        if known.contains(cmd) { return "/usr/bin/\(cmd)" }
        return "\(cmd) not found"
    }

    private func treeOutput(_ cwd: String) -> String {
        guard let node = resolveNode(cwd), let children = node.children else { return "." }
        var lines = ["."]
        for (i, child) in children.enumerated() {
            let prefix = i == children.count - 1 ? "└── " : "├── "
            lines.append(prefix + child.name)
        }
        lines.append("\n\(children.filter { $0.isFolder }.count) directories, \(children.filter { !$0.isFolder }.count) files")
        return lines.joined(separator: "\n")
    }

    // MARK: - System Info

    private func unameOutput(_ args: [String]) -> String {
        if args.contains("-a") {
            return "Darwin MacBook-Pro.local 24.4.0 Darwin Kernel Version 24.4.0: root:xnu-11215.101.130~2/RELEASE_ARM64_T6031 arm64"
        }
        return "Darwin"
    }

    private var uptimeOutput: String {
        let uptime = ProcessInfo.processInfo.systemUptime
        let days = Int(uptime) / 86400
        let hours = (Int(uptime) % 86400) / 3600
        let mins = (Int(uptime) % 3600) / 60
        return " \(Date().formatted(date: .omitted, time: .shortened))  up \(days) days, \(hours):\(String(format: "%02d", mins)),  1 user,  load averages: 1.42 1.38 1.35"
    }

    private var swVersOutput: String {
        "ProductName:\t\tmacOS\nProductVersion:\t\t15.4\nBuildVersion:\t\t24E248"
    }

    private var sysctlOutput: String {
        let cores = ProcessInfo.processInfo.activeProcessorCount
        let mem = ProcessInfo.processInfo.physicalMemory / (1024 * 1024 * 1024)
        return "hw.ncpu: \(cores)\nhw.memsize: \(mem * 1073741824)\nhw.machine: arm64\nmachdep.cpu.brand_string: Apple M4 Pro"
    }

    private var topOutput: String {
        let mem = ProcessInfo.processInfo.physicalMemory / (1024 * 1024)
        return "Processes: 384 total, 2 running, 382 sleeping, 1842 threads\nPhysMem: \(mem)M used (2048M wired), 4096M unused.\nCPU usage: 3.2% user, 1.8% sys, 95.0% idle"
    }

    private var psOutput: String {
        "  PID TTY           TIME CMD\n    1 ??         2:34.56 /sbin/launchd\n  142 ??         0:12.34 /usr/sbin/cfprefsd\n  287 ??         1:56.78 /usr/libexec/WindowServer\n  501 ttys000    0:00.01 -zsh\n  823 ttys000    0:00.00 ps"
    }

    private var dfOutput: String {
        guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
              let total = attrs[.systemSize] as? Int64,
              let free = attrs[.systemFreeSize] as? Int64 else { return "df: error" }
        let totalGB = total / 1_073_741_824
        let usedGB = (total - free) / 1_073_741_824
        return "Filesystem     Size   Used  Avail Capacity  Mounted on\n/dev/disk3s1  \(totalGB)G   \(usedGB)G   \(totalGB - usedGB)G    \(usedGB * 100 / totalGB)%    /"
    }

    private var memoryOutput: String {
        let mem = ProcessInfo.processInfo.physicalMemory
        let memGB = mem / (1024 * 1024 * 1024)
        return "              total        used        free\nMem:          \(memGB)Gi       \(memGB * 2 / 3)Gi       \(memGB / 3)Gi"
    }

    private var envOutput: String {
        "HOME=/Users/admin\nUSER=admin\nSHELL=/bin/zsh\nPATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin\nTERM=xterm-256color\nLANG=en_US.UTF-8\nLC_ALL=en_US.UTF-8\nEDITOR=vim\nLOGNAME=admin\nTMPDIR=/var/folders/xx/xxxxx/T/"
    }

    // MARK: - Date/Calendar

    private func dateOutput(_ args: [String]) -> String {
        if args.contains("+%s") { return "\(Int(Date().timeIntervalSince1970))" }
        return Date().formatted(date: .complete, time: .standard)
    }

    private var calOutput: String {
        let cal = Calendar.current
        let now = Date()
        let month = cal.component(.month, from: now)
        let year = cal.component(.year, from: now)
        let today = cal.component(.day, from: now)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let header = formatter.string(from: now)

        var lines = ["    \(header)", "Su Mo Tu We Th Fr Sa"]
        let comps = cal.dateComponents([.year, .month], from: now)
        guard let firstDay = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: firstDay) else { return header }
        let weekday = cal.component(.weekday, from: firstDay) - 1
        var line = String(repeating: "   ", count: weekday)
        for day in range {
            let dayStr = day == today ? "\(day)*" : "\(day)"
            line += String(format: "%2s ", dayStr)
            if (day + weekday) % 7 == 0 { lines.append(line); line = "" }
        }
        if !line.isEmpty { lines.append(line) }
        return lines.joined(separator: "\n")
    }

    // MARK: - Network

    private var ifconfigOutput: String {
        "en0: flags=8863<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> mtu 1500\n\tinet 192.168.1.\(Int.random(in: 100...200)) netmask 0xffffff00 broadcast 192.168.1.255\n\tether a4:83:e7:xx:xx:xx\n\tstatus: active"
    }

    private func pingOutput(_ args: [String]) -> String {
        let host = args.first ?? "localhost"
        return "PING \(host) (93.184.216.34): 56 data bytes\n64 bytes from 93.184.216.34: icmp_seq=0 ttl=56 time=\(Int.random(in: 10...50))ms\n64 bytes from 93.184.216.34: icmp_seq=1 ttl=56 time=\(Int.random(in: 10...50))ms\n--- \(host) ping statistics ---\n2 packets transmitted, 2 packets received, 0.0% packet loss"
    }

    // MARK: - Package Managers

    private func brewOutput(_ args: [String]) -> String {
        if args.first == "list" {
            return "cmake\ngit\nnode\npython@3.12\nrubby\nwget\nffmpeg\nImageMagick"
        }
        if args.first == "--version" { return "Homebrew 4.2.10" }
        if args.first == "install" { return "==> Downloading \(args.last ?? "package")...\n==> Installing \(args.last ?? "package")\n🍺 /usr/local/Cellar/\(args.last ?? "package")/1.0" }
        return "Homebrew 4.2.10\nUsage: brew [info|install|list|search|update|upgrade]"
    }

    private func gitOutput(_ args: [String]) -> String {
        if args.isEmpty || args.first == "--version" { return "git version 2.43.0" }
        if args.first == "status" { return "On branch main\nnothing to commit, working tree clean" }
        if args.first == "branch" { return "* main\n  develop\n  feature/macfake" }
        if args.first == "log" { return "commit abc123 (HEAD -> main)\nAuthor: Admin <admin@macbook.local>\nDate:   \(Date().formatted())\n\n    Initial commit" }
        return "git: '\(args.first ?? "")' is not a git command."
    }

    // MARK: - Fun

    private func cowsay(_ text: String) -> String {
        let msg = text.isEmpty ? "Moo!" : text
        let border = String(repeating: "-", count: msg.count + 2)
        return " \(border)\n< \(msg) >\n \(border)\n        \\   ^__^\n         \\  (oo)\\_______\n            (__)\\       )\\/\\\n                ||----w |\n                ||     ||"
    }

    private var fortune: String {
        let quotes = [
            "The best way to predict the future is to invent it. — Alan Kay",
            "Talk is cheap. Show me the code. — Linus Torvalds",
            "First, solve the problem. Then, write the code. — John Johnson",
            "Any fool can write code that a computer can understand. Good programmers write code that humans can understand. — Martin Fowler",
            "Code is like humor. When you have to explain it, it's bad. — Cory House",
        ]
        return quotes.randomElement() ?? quotes[0]
    }

    private func manOutput(_ args: [String]) -> String {
        guard let cmd = args.first else { return "What manual page do you want?" }
        return "\(cmd.uppercased())(1)\t\tGeneral Commands Manual\n\nNAME\n     \(cmd) – \(cmd) command\n\nSYNOPSIS\n     \(cmd) [options] [arguments]\n\nDESCRIPTION\n     The \(cmd) utility performs \(cmd) operations.\n\nmacOS 15.4\t\tApril 30, 2026"
    }

    // MARK: - Echo with variable expansion

    private func echoCommand(_ args: [String]) -> String {
        var output = args.joined(separator: " ")
        output = output.replacingOccurrences(of: "$HOME", with: "/Users/admin")
        output = output.replacingOccurrences(of: "$USER", with: "admin")
        output = output.replacingOccurrences(of: "$SHELL", with: "/bin/zsh")
        output = output.replacingOccurrences(of: "$PATH", with: "/usr/local/bin:/usr/bin:/bin")
        output = output.replacingOccurrences(of: "$PWD", with: "/Users/admin")
        return output
    }

    // MARK: - Neofetch

    private var neofetchOutput: String {
        let cores = ProcessInfo.processInfo.activeProcessorCount
        let memGB = ProcessInfo.processInfo.physicalMemory / (1024 * 1024 * 1024)
        return """
                        .:'          admin@MacBook-Pro
                    __ :'.__        -------------------
                 .'`  `-'  ``.     OS: macOS Sequoia 15.4
                :          .-'     Host: MacBook Pro (M4 Pro)
                :         :        Kernel: Darwin 24.4.0
                 :   _/   ::       Uptime: \(uptimeShort)
                 `. (  -.``'       Shell: zsh 5.9
                   `-._            Terminal: MacFake Terminal
                                   CPU: Apple M4 Pro (\(cores)-core)
                                   Memory: \(memGB * 2 / 3) GiB / \(memGB) GiB
        """
    }

    private var uptimeShort: String {
        let up = ProcessInfo.processInfo.systemUptime
        return "\(Int(up) / 86400) days, \((Int(up) % 86400) / 3600) hours"
    }

    // MARK: - Helpers

    private var helpText: String {
        """
        MacFake Terminal — Available commands:

        File System:  ls, cd, pwd, cat, find, tree, which, file, wc
        System Info:  whoami, hostname, uname, uptime, id, sw_vers, top, ps, df
        Text/Output:  echo, printf, date, cal
        Network:      ifconfig, ping, nslookup, dig
        Dev Tools:    git, brew, python3, node, swift, ruby, npm, pip
        Package Mgr:  brew install/list/search
        Fun:          neofetch, cowsay, fortune, sl
        Other:        clear, history, alias, env, man, help, exit
        """
    }

    // MARK: - Resolve Node

    private func resolveNode(_ path: String) -> FakeNode? {
        let components = path.components(separatedBy: "/").filter { !$0.isEmpty }
        var current = fileSystem.root
        for component in components {
            guard let child = current.children?.first(where: { $0.name == component }) else { return nil }
            current = child
        }
        return current
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM dd HH:mm"
        return f.string(from: date)
    }
}

struct CommandResult {
    let output: String
    let newCwd: String
}
