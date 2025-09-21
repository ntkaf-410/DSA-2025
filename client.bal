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
    