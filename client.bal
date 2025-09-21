import ballerina/io;
import ballerina/http;

// Status enumeration
public enum AssetStatus {
    ACTIVE,
    UNDER_REPAIR,
    DISPOSED
}

// Component record
type Component record {
    string componentId;
    string name;
    string description;
    string status;
};

// Maintenance Schedule record
type Schedule record {
    string scheduleId;
    string scheduleType;
    string nextDueDate;
    string description;
};

// Task record
type Task record {
    string taskId;
    string description;
    string status;
    string assignedTo?;
};

// Work Order record
type WorkOrder record {
    string workOrderId;
    string description;
    string status;
    string createdDate;
    string priority?;
    Task[] tasks;
};

// Asset record
type Asset record {
    readonly string assetTag;
    string name;
    string faculty;
    string department;
    AssetStatus status;
    string acquiredDate;
    map<Component> components;
    map<Schedule> schedules;
    map<WorkOrder> workOrders;
};

http:Client assetClient = check new ("http://localhost:9090/asset_management");

public function main() returns error? {
    io:println("NUST Asset Management System");
    io:println("============================\n");
    
    // Test the system with sample data
    check demonstrateAssetManagement();
    
    // Interactive menu
    while true {
        io:println("\nChoose an action:");
        io:println("1. Add a new asset");
        io:println("2. View all assets");
        io:println("3. View asset by tag");
        io:println("4. Update asset");
        io:println("5. Delete asset");
        io:println("6. View assets by faculty");
        io:println("7. Check overdue maintenance");
        io:println("8. Manage components");
        io:println("9. Manage schedules");
        io:println("10. Manage work orders");
        io:println("11. Exit");
        
        string choice = io:readln("Enter your choice (1-11): ");
        
        if choice == "11" {
            io:println("Goodbye!");
            break;
        }
        
        check handleMenuChoice(choice);
    }
}

function demonstrateAssetManagement() returns error? {
    io:println("=== Demonstrating Asset Management System ===\n");
    
     // 1. Adding assets
    io:println("1. Adding sample assets...");
    
    Asset printer = {
        assetTag: "EQ-001",
        name: "3D Printer",
        faculty: "Computing & Informatics",
        department: "Software Engineering",
        status: ACTIVE,
        acquiredDate: "2024-03-10",
        components: {},
        schedules: {},
        workOrders: {}
    };
    
    Asset|error printerResult = assetClient->/assets.post(printer);
    if printerResult is Asset {
        io:println("✓ Added 3D Printer: " + printerResult.assetTag);
    }
    
    Asset server = {
        assetTag: "EQ-002",
        name: "Dell Server",
        faculty: "Computing & Informatics",
        department: "Computer Science",
        status: ACTIVE,
        acquiredDate: "2020-01-15", // Older for overdue demo
        components: {},
        schedules: {},
        workOrders: {}
    };
    
    Asset|error serverResult = assetClient->/assets.post(server);
    if serverResult is Asset {
        io:println("✓ Added Dell Server: " + serverResult.assetTag);
    }
    
    // 2. Viewing all assets
    io:println("\n2. Viewing all assets...");
    Asset[]|error allAssets = assetClient->/assets;
    if allAssets is Asset[] {
        io:println("Total assets: " + allAssets.length().toString());
        foreach Asset asset in allAssets {
            io:println("- " + asset.assetTag + ": " + asset.name + " (" + asset.faculty + ")");
        }
    }

// 3. Viewing by faculty
    io:println("\n3. Viewing assets by faculty...");
    Asset[]|error facultyAssets = assetClient->/assets/faculty/["Computing & Informatics"];
    if facultyAssets is Asset[] {
        io:println("Assets in Computing & Informatics: " + facultyAssets.length().toString());
    }
        