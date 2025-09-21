import ballerina/http;
import ballerina/time;

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
    string scheduleType; // e.g., "quarterly", "yearly"
    string nextDueDate; // ISO date string
    string description;
};

// Task record
type Task record {
    string taskId;
    string description;
    string status; // e.g., "pending", "in_progress", "completed"
    string assignedTo?;
};

// Work Order record
type WorkOrder record {
    string workOrderId;
    string description;
    string status; // e.g., "open", "in_progress", "closed"
    string createdDate;
    string priority?; // e.g., "low", "medium", "high"
    Task[] tasks;
};

// Asset record
type Asset record {
    readonly string assetTag;
    string name;
    string faculty;
    string department;
    AssetStatus status;
    string acquiredDate; // ISO date string
    map<Component> components;
    map<Schedule> schedules;
    map<WorkOrder> workOrders;
};

// Main asset database
table<Asset> key(assetTag) assetDatabase = table [];

service /asset_management on new http:Listener(9090) {
