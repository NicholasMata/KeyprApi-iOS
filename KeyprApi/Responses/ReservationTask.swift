//
//  KeyprTask.swift
//  KeyprApi
//
//  Created by Nicholas Mata on 11/29/18.
//  Copyright © 2018 Nicholas Mata. All rights reserved.
//

import Foundation

/// A async task that was start or performed on a reservation
public class ReservationTask: Codable {
    /// The task identifier, usual to check the status of the task again.
    public var id: String
    /// The type of task, *reservation, task_status* is what I have seen.
    public var type: String
    /// Attributes about the task
    public var attributes: Attributes
    
    public enum Status: String, Codable {
        case pending = "PENDING"
        case success = "SUCCESS"
        case failure = "FAILURE"
    }
    
    /// Attributes about a task
    public class Attributes: Codable {
        /// Unknown - The name of task?
        public var name: String?
        /// The status of the task PENDING, SUCCESS, FAILURE
        public var status: ReservationTask.Status
        /// The result of the task (only seen this on a FAILURE).
        public var result: [String]?
        /// Whether or not the task has completed.
        public var ready: Bool
        /// Whether the task completed successfully.
        public var successful: Bool
        /// Whether the task failed.
        public var failed: Bool
        /// A url to check the status of a task.
        public var statusUrl: String?
    }
    
}
