//
//  Strand.swift
//  Strand
//
//  Created by James Richard on 3/1/16.
//

import Darwin.C

public enum StrandError: Error {
  case threadCreationFailed
  case threadCancellationFailed(Int)
  case threadJoinFailed(Int)
}

public class Strand {
  private var pthread: pthread_t
  
  public init(closure: @escaping () -> Void) throws {
    let holder = Unmanaged.passRetained(StrandClosure(closure: closure))
    
    let pointer = UnsafeMutableRawPointer(holder.toOpaque())
    var pt: pthread_t?
    guard pthread_create(&pt, nil, runner, pointer) == 0 && pt != nil else {
      holder.release()
      throw StrandError.threadCreationFailed
    }
    pthread = pt!
  }
  
  public func join() throws {
    let status = pthread_join(pthread, nil)
    if status != 0 {
      throw StrandError.threadJoinFailed(Int(status))
    }
  }
  
  public func cancel() throws {
    let status = pthread_cancel(pthread)
    if status != 0 {
      throw StrandError.threadCancellationFailed(Int(status))
    }
  }
  
  public class func exit(code: inout Int) {
    pthread_exit(&code)
  }
  
  deinit {
    pthread_detach(pthread)
  }
}

private func runner(arg: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
  let unmanaged = Unmanaged<StrandClosure>.fromOpaque(arg)
  unmanaged.takeUnretainedValue().closure()
  unmanaged.release()
  return nil
}

private class StrandClosure {
  let closure: () -> Void
  
  init(closure: @escaping () -> Void) {
    self.closure = closure
  }
}
