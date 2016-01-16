//
//  AbstractOperation.swift
//  CompositeOperations
//
//  Created by Stanislaw Pankevich on 16/01/16.
//  Copyright © 2016 Stanislaw Pankevich. All rights reserved.
//

import Foundation

class AbstractOperation : NSOperation, Operation {
    enum OperationState {
        case Ready
        case Executing
        case Finished(OperationResult)

        func toString() -> String {
            switch self {
                case Ready:
                    return "isReady"
                case Executing:
                    return "isExecuting"
                case Finished(_):
                    return "isFinished"
            }
        }
    }

    var _state: OperationState = .Ready
    var state: OperationState {
        get {
            return _state
        }

        set {
            let oldStateString = _state.toString()
            let newStateString = newValue.toString()

            willChangeValueForKey(newStateString)
            willChangeValueForKey(oldStateString)
            _state = newValue
            didChangeValueForKey(oldStateString)
            didChangeValueForKey(newStateString)
        }
    }

    final override var ready: Bool {
        switch state {
        case .Ready:
            return true
        default:
            return false
        }
    }

    final override var executing: Bool {
        switch state {
        case .Executing:
            return true
        default:
            return false
        }
    }

    final override var finished: Bool {
        switch state {
        case .Finished(_):
            return true
        default:
            return false
        }
    }

    final var result: OperationResult? {
        switch state {
        case .Finished(let result):
            return result
        default:
            return nil
        }
    }

    final override func start() {
        if ready {
            state = .Executing;

            if cancelled {
                state = .Finished(.Cancelled)
            } else {
                self.main()
            }
        }
    }
}
