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

  // 4. Adding a component
    io:println("\n4. Adding component to 3D Printer...");
    Component printHead = {
        componentId: "COMP-001",
        name: "Print Head",
        description: "Main printing component",
        status: "working"
    };
    
    Component|error componentResult = assetClient->/assets/["EQ-001"]/components.post(printHead);
    if componentResult is Component {
        io:println("✓ Added component: " + componentResult.name);
    }

// 5. Adding a schedule (overdue for demonstration)
    io:println("\n5. Adding maintenance schedule...");
    Schedule maintenance = {
        scheduleId: "SCH-001",
        scheduleType: "quarterly",
        nextDueDate: "2024-01-01T00:00:00Z", // Past date for overdue demo
        description: "Quarterly maintenance check"
    };
    
    Schedule|error scheduleResult = assetClient->/assets/["EQ-002"]/schedules.post(maintenance);
    if scheduleResult is Schedule {
        io:println("✓ Added maintenance schedule: " + scheduleResult.scheduleType);
    }
    
    // 6. Checking overdue items
    io:println("\n6. Checking for overdue maintenance...");
    Asset[]|error overdueAssets = assetClient->/assets/overdue;
    if overdueAssets is Asset[] {
        io:println("Overdue assets: " + overdueAssets.length().toString());
        foreach Asset asset in overdueAssets {
            io:println("⚠️  " + asset.assetTag + ": " + asset.name + " has overdue maintenance");
        }
    }
    
    io:println("\n=== Demonstration Complete ===");
}
function handleMenuChoice(string choice) returns error? {
    match choice {
        "1" => {
            check addNewAsset();
        }
        "2" => {
            check viewAllAssets();
        }
        "3" => {
            check viewAssetByTag();
        }
        "4" => {
            check updateAsset();
        }
        "5" => {
            check deleteAsset();
        }
        "6" => {
            check viewAssetsByFaculty();
        }
        "7" => {
            check checkOverdueAssets();
        }
        "8" => {
            check manageComponents();
        }
        "9" => {
            check manageSchedules();
        }
        "10" => {
            check manageWorkOrders();
        }
        _ => {
            io:println("Invalid choice. Please try again.");
        }
    }
}


function addNewAsset() returns error? {
    io:println("\n--- Add New Asset ---");
    string assetTag = io:readln("Asset Tag: ");
    string name = io:readln("Asset Name: ");
    string faculty = io:readln("Faculty: ");
    string department = io:readln("Department: ");
    string statusStr = io:readln("Status (ACTIVE/UNDER_REPAIR/DISPOSED): ");
    string acquiredDate = io:readln("Acquired Date (YYYY-MM-DD): ");
    
    AssetStatus status = statusStr == "UNDER_REPAIR" ? UNDER_REPAIR : 
                        statusStr == "DISPOSED" ? DISPOSED : ACTIVE;
    
    Asset newAsset = {
        assetTag: assetTag,
        name: name,
        faculty: faculty,
        department: department,
        status: status,
        acquiredDate: acquiredDate,
        components: {},
        schedules: {},
        workOrders: {}
    };
    
    Asset|error result = assetClient->/assets.post(newAsset);
    if result is Asset {
        io:println("✓ Asset added successfully: " + result.assetTag);
    } else {
        io:println("✗ Error adding asset: " + result.message());
    }
}

function viewAllAssets() returns error? {
    io:println("\n--- All Assets ---");
    Asset[]|error assets = assetClient->/assets;
    if assets is Asset[] {
        if assets.length() == 0 {
            io:println("No assets found.");
        } else {
            foreach Asset asset in assets {
                io:println(asset.assetTag + " | " + asset.name + " | " + asset.faculty + " | " + asset.status.toString());
            }
        }
    } else {
        io:println("✗ Error retrieving assets: " + assets.message());
    }
}

function viewAssetByTag() returns error? {
    io:println("\n--- View Asset by Tag ---");
    string assetTag = io:readln("Enter Asset Tag: ");
    
    Asset|error asset = assetClient->/assets/[assetTag];
    if asset is Asset {
        io:println("Asset Details:");
        io:println("Tag: " + asset.assetTag);
        io:println("Name: " + asset.name);
        io:println("Faculty: " + asset.faculty);
        io:println("Department: " + asset.department);
        io:println("Status: " + asset.status.toString());
        io:println("Acquired: " + asset.acquiredDate);
        io:println("Components: " + asset.components.length().toString());
        io:println("Schedules: " + asset.schedules.length().toString());
        io:println("Work Orders: " + asset.workOrders.length().toString());
    } else {
        io:println("✗ Asset not found.");
    }
}

function updateAsset() returns error? {
    io:println("\n--- Update Asset ---");
    string assetTag = io:readln("Asset Tag to update: ");
    string name = io:readln("New Asset Name (or press Enter to skip): ");
    string faculty = io:readln("New Faculty (or press Enter to skip): ");
    string department = io:readln("New Department (or press Enter to skip): ");
    string statusStr = io:readln("New Status (ACTIVE/UNDER_REPAIR/DISPOSED, or press Enter to skip): ");
    
    AssetStatus status = statusStr == "UNDER_REPAIR" ? UNDER_REPAIR : 
                        statusStr == "DISPOSED" ? DISPOSED : ACTIVE;
    
    Asset updatedAsset = {
        assetTag: assetTag,
        name: name,
        faculty: faculty,
        department: department,
        status: status,
        acquiredDate: "",
        components: {},
        schedules: {},
        workOrders: {}
    };
    
    Asset|error result = assetClient->/assets/[assetTag].put(updatedAsset);
    if result is Asset {
        io:println("✓ Asset updated successfully.");
    } else {
        io:println("✗ Error updating asset: " + result.message());
    }
}

function deleteAsset() returns error? {
    io:println("\n--- Delete Asset ---");
    string assetTag = io:readln("Asset Tag to delete: ");
    
    Asset|error result = assetClient->/assets/[assetTag].delete();
    if result is Asset {
        io:println("✓ Asset deleted: " + result.assetTag);
    } else {
        io:println("✗ Error deleting asset: " + result.message());
    }
}

function viewAssetsByFaculty() returns error? {
    io:println("\n--- View Assets by Faculty ---");
    string faculty = io:readln("Faculty name: ");
    
    Asset[]|error assets = assetClient->/assets/faculty/[faculty];
    if assets is Asset[] {
        if assets.length() == 0 {
            io:println("No assets found in " + faculty);
        } else {
            io:println("Assets in " + faculty + ":");
            foreach Asset asset in assets {
                io:println("- " + asset.assetTag + ": " + asset.name);
            }
        }
    } else {
        io:println("✗ Error retrieving assets: " + assets.message());
    }
}

function checkOverdueAssets() returns error? {
    io:println("\n--- Overdue Maintenance Check ---");
    Asset[]|error assets = assetClient->/assets/overdue;
    if assets is Asset[] {
        if assets.length() == 0 {
            io:println("No assets have overdue maintenance.");
        } else {
            io:println("Assets with overdue maintenance:");
            foreach Asset asset in assets {
                io:println("⚠️  " + asset.assetTag + ": " + asset.name);
            }
        }
    } else {
        io:println("✗ Error checking overdue assets: " + assets.message());
    }
}
function manageComponents() returns error? {
    io:println("\n--- Component Management ---");
    io:println("1. Add component");
    io:println("2. Remove component");
    
    string choice = io:readln("Choose action (1-2): ");
    
    if choice == "1" {
        string assetTag = io:readln("Asset Tag: ");
        string componentId = io:readln("Component ID: ");
        string name = io:readln("Component Name: ");
        string description = io:readln("Description: ");
        string status = io:readln("Status: ");
        
        Component component = {
            componentId: componentId,
            name: name,
            description: description,
            status: status
        };
        
        Component|error result = assetClient->/assets/[assetTag]/components.post(component);
        if result is Component {
            io:println("✓ Component added successfully.");
        } else {
            io:println("✗ Error adding component: " + result.message());
        }
    } else if choice == "2" {
        string assetTag = io:readln("Asset Tag: ");
        string componentId = io:readln("Component ID to remove: ");
        
        Component|error result = assetClient->/assets/[assetTag]/components/[componentId].delete();
        if result is Component {
            io:println("✓ Component removed successfully.");
        } else {
            io:println("✗ Error removing component: " + result.message());
        }
    }
}
