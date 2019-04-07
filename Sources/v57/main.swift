import SomeFunctions

terminal.add(function: "install") {
  let dir = shell("/bin/pwd").replacingOccurrences(of: "\n", with: "")
  let projectName = dir.fileURL.name
  shell("/usr/bin/swift build -c release")
  shell("/bin/cp \(dir)/.build/release/\(projectName) /usr/local/bin/\(projectName)")
}
terminal.add(advanced: "sgit") { (function) in
  var path = try function.string().split(separator: "/").map{ String($0) }
  if path.count == 1 {
    path.append(path[0])
  }
  if let name = try? function.string() {
    path.append(name)
  } else {
    path.append(path[1])
  }
  let repository = "\(path[0])/\(path[1])"
  let url = "git@github.com:\(repository).git"
  let output = FileURL(path: "~/github/\(path[0])/\(path[2])").path
  let result = shell("/usr/bin/git clone", url, output)
  print(result)
}
terminal.add(advanced: "git") { (function) in
  var path = try function.string().split(separator: "/").map{ String($0) }
  if path.count == 1 {
    path.append(path[0])
  }
  if let name = try? function.string() {
    path.append(name)
  } else {
    path.append(path[1])
  }
  let repository = "\(path[0])/\(path[1])"
  let url = "https://github.com/\(repository).git"
  let output = FileURL(path: "~/github/\(path[0])/\(path[2])").path
  let result = shell("/usr/bin/git clone", url, output)
  print(result)
}
if CommandLine.arguments.count == 1 {
  terminal.singleListen()
} else {
  let command = CommandLine.arguments[1...].joined(separator: " ")
  terminal.run(command)
}
//git@github.com:PLAYGRA/Playgra.git
