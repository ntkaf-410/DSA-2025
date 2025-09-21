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

  // Create a new asset
    resource function post assets(@http:Payload Asset newAsset) returns Asset|http:BadRequest|http:Conflict {
        if (assetDatabase.hasKey(newAsset.assetTag)) {
            return http:CONFLICT;
        }
        assetDatabase.put(newAsset);
        return newAsset;
    }

    // Get all assets
    resource function get assets() returns Asset[] {
        Asset[] allAssets = [];
        foreach Asset asset in assetDatabase {
            allAssets.push(asset);
        }
        return allAssets;
    }

    // Get asset by tag
    resource function get assets/[string assetTag]() returns Asset|http:NotFound {
        Asset? asset = assetDatabase[assetTag];
        if (asset is ()) {
            return http:NOT_FOUND;
        }
        return asset;
    }

    // Update asset
    resource function put assets/[string assetTag](@http:Payload Asset updatedAsset) returns Asset|http:NotFound {
        Asset? existingAssetOpt = assetDatabase[assetTag];
        if (existingAssetOpt is ()) {
            return http:NOT_FOUND;
        }
        
        Asset existingAsset = existingAssetOpt;
        
        // Update fields while preserving the key
        Asset newAsset = {
            assetTag: existingAsset.assetTag, // Keep the original key
            name: updatedAsset.name != "" ? updatedAsset.name : existingAsset.name,
            faculty: updatedAsset.faculty != "" ? updatedAsset.faculty : existingAsset.faculty,
            department: updatedAsset.department != "" ? updatedAsset.department : existingAsset.department,
            status: updatedAsset.status,
            acquiredDate: updatedAsset.acquiredDate != "" ? updatedAsset.acquiredDate : existingAsset.acquiredDate,
            components: updatedAsset.components.length() > 0 ? updatedAsset.components : existingAsset.components,
            schedules: updatedAsset.schedules.length() > 0 ? updatedAsset.schedules : existingAsset.schedules,
            workOrders: updatedAsset.workOrders.length() > 0 ? updatedAsset.workOrders : existingAsset.workOrders
        };
        
        assetDatabase.put(newAsset);
        return newAsset;
    }

    // Delete asset
    resource function delete assets/[string assetTag]() returns Asset|http:NotFound {
        Asset? asset = assetDatabase[assetTag];
        if (asset is ()) {
            return http:NOT_FOUND;
        }
        return assetDatabase.remove(assetTag);
    }
