//
//  MCSLock.swift
//  MCSLocck
//
//  Created by Ebubechukwu Dimobi on 19.12.2021.
//

import Foundation

// MCS Queue Lock maintains a linked-list for
// threads waiting to enter critical section (CS).
//
// Each thread that wants to enter CS joins at the
// end of the queue, and waits for the thread
// infront of it to finish its CS.
//
// So, it locks itself and asks the thread infront
// of it, to unlock it when he's done. Atomics
// instructions are used when updating the shared
// queue. Corner cases are also takes care of.
//
// As each thread waits (spins) on its own "locked"
// field, this type of lock is suitable for
// cache-less NUMA architectures.

//NSLocking is a protocol(interface) wtih two methods
class MCSLock: NSLocking {
    
    // tail: points to the tail, last item on the queue
    // node:  is unique for each thread
    var tail: Atomic<QNode>
    let node: ThreadLocal<QNode>
    
    init() {
        tail = Atomic(value: nil)
        node = ThreadLocal(value: QNode())
    }
    
    // 1. When thread wants to access critical
    //    section, it stands at the end of the
    //    queue (FIFO).
    // 2a. If there is no one in queue, it goes head
    //     with its critical section.
    // 2b. Otherwise, it locks itself and asks the
    //     thread infront of it to unlock it when its
    //     done with CS.
    func lock() {
        let threadNode = node.inner.get()             //1
        let threadTail = tail.getAndSet(threadNode)  //1
        
        if threadTail != nil {                     //2b
            threadNode.isLocked = true             //2b
            threadTail?.next = threadNode          //2b
            while threadNode.isLocked { }  //2b
        }
    }
    
    // 1. When a thread is done with its critical
    //    section, it needs to unlock any thread
    //    standing behind it.
    // 2a. If there is a thread standing behind,
    //     then it unlocks him.
    // 2b. Otherwise it tries to mark queue as empty.
    //     If no one is joining, it leaves.
    // 2c. If there is a thread trying to join the
    //     queue, it waits until he is done, and then
    //     unlocks him, and leaves.
    func unlock() {
        let threadNode = node.inner.get()                                       //1
        if threadNode.next == nil {                                             //2b
            if tail.compareAndSet(valueToCompare: threadNode, newValue: nil) {  //2b
                return                                                          //2b
            }
            while threadNode.next == nil { }   //2c
        }
        threadNode.next?.isLocked = false      // 2a
        threadNode.next = nil                  //2a
    }
}
