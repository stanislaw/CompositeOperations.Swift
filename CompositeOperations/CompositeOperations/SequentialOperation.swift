//
//  SequentialOperation.swift
//  CompositeOperations
//
//  Created by Stanislaw Pankevich on 16/01/16.
//  Copyright © 2016 Stanislaw Pankevich. All rights reserved.
//

import Foundation

enum CompositeOperationResult {
    case Results([OperationResult])
    case Errors([OperationResult?])
    case Cancelled
}

class SequentialOperation : AbstractOperation {
    var completion: ((CompositeOperationResult) -> Void)?
    var operations: [Operation] = [Operation]()

    let sequence: Sequence

    init(sequence: Sequence) {
        self.sequence = sequence
    }

    func runNextOperation(lastFinishedOperationOrNil: Operation?) {
        if cancelled {
            finish(.Cancelled)

            return
        }

        let nextOperation = self.sequence.nextOperation(lastFinishedOperationOrNil)

        if var nextOperation = nextOperation {
            operations.append(nextOperation)

            nextOperation.completionBlock = {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.runNextOperation(nextOperation)
                })
            }

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                nextOperation.start()
            })
        } else {
            _finish()
        }
    }

    final func _finish() {
        if let lastOperation = operations.last {
            if let lastOperationResult = lastOperation.result {
                switch lastOperationResult {
                    case .Error(_):
                        let errors = operations.map({ (operation) -> OperationResult? in
                            return operation.result
                        })

                        finish(.Errors(errors))

                        return
                    default:
                        break
                }
            }
        }

        let results = operations.map({ (operation) -> OperationResult in
            return operation.result!
        })

        finish(.Results(results))
    }

    final func finish(result: CompositeOperationResult) {
        state = .Finished(.Result(result))

        if let completion = completion {
            completion(result)
        }
    }

    final override func main() {
        runNextOperation(nil)
    }
}
