//
//  Database.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 12.08.25.
//

import Dependencies
import Foundation
import SQLiteData

extension DependencyValues {
    mutating func bootstrapDatabase() throws {
        let database = try SQLiteData.defaultDatabase()
        var migrator = DatabaseMigrator()
        
        #if DEBUG
            migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        migrator.registerMigration("Create ticketRecords table") { db in
            try #sql("""
                CREATE TABLE "ticketRecords" (
                    "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE,
                    "hash" TEXT,
                    "customerId" TEXT,
                    "status" TEXT,
                    "expiresAt" TEXT,
                    "createdAt" TEXT,
                    "eventId" TEXT,
                    "ticketTypeId" TEXT,
                    "isScanned" INTEGER NOT NULL DEFAULT 0,
                    "scannedAt" TEXT,
                    "needsSync" INTEGER NOT NULL DEFAULT 0
                ) STRICT
            """).execute(db)
        }
        
        try migrator.migrate(database)
        defaultDatabase = database
    }
}
