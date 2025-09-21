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

// Get assets by faculty
    resource function get assets/faculty/[string faculty]() returns Asset[] {
        Asset[] facultyAssets = [];
        foreach Asset asset in assetDatabase {
            if (asset.faculty == faculty) {
                facultyAssets.push(asset);
            }
        }
        return facultyAssets;
    }

    // Get overdue assets
    resource function get assets/overdue() returns Asset[]|error {
        Asset[] overdueAssets = [];
        time:Utc currentTime = time:utcNow();
        
        foreach Asset asset in assetDatabase {
            foreach Schedule schedule in asset.schedules {
                time:Utc|time:Error dueTime = time:utcFromString(schedule.nextDueDate);
                if (dueTime is time:Utc && time:utcDiffSeconds(currentTime, dueTime) > 0.0d) {
                    overdueAssets.push(asset);
                    break; // Asset already added, no need to check other schedules
                }
            }
        }
        return overdueAssets;
    }
// Component Management


    // Add component to asset
    resource function post assets/[string assetTag]/components(@http:Payload Component newComponent) returns Component|http:NotFound {
        Asset? assetOpt = assetDatabase[assetTag];
        if (assetOpt is ()) {
            return http:NOT_FOUND;
        }
        
        Asset asset = assetOpt;
        asset.components[newComponent.componentId] = newComponent;
        assetDatabase.put(asset);
        return newComponent;
    }

    // Remove component from asset
    resource function delete assets/[string assetTag]/components/[string componentId]() returns Component|http:NotFound {
        Asset? assetOpt = assetDatabase[assetTag];
        if (assetOpt is ()) {
            return http:NOT_FOUND;
        }
        
        Asset asset = assetOpt;
        if (!asset.components.hasKey(componentId)) {
            return http:NOT_FOUND;
        }
        
        Component removedComponent = asset.components.remove(componentId);
        assetDatabase.put(asset);
        return removedComponent;
    }

// Schedule Management
    
    // Add schedule to asset
    resource function post assets/[string assetTag]/schedules(@http:Payload Schedule newSchedule) returns Schedule|http:NotFound {
        Asset? assetOpt = assetDatabase[assetTag];
        if (assetOpt is ()) {
            return http:NOT_FOUND;
        }
        
        Asset asset = assetOpt;
        asset.schedules[newSchedule.scheduleId] = newSchedule;
        assetDatabase.put(asset);
        return newSchedule;
    }

    // Remove schedule from asset
    resource function delete assets/[string assetTag]/schedules/[string scheduleId]() returns Schedule|http:NotFound {
        Asset? assetOpt = assetDatabase[assetTag];
        if (assetOpt is ()) {
            return http:NOT_FOUND;
        }
        
        Asset asset = assetOpt;
        if (!asset.schedules.hasKey(scheduleId)) {
            return http:NOT_FOUND;
        }
        
        Schedule removedSchedule = asset.schedules.remove(scheduleId);
        assetDatabase.put(asset);
        return removedSchedule;
    }

    // Work Order Management
    
    // Create work order
    resource function post assets/[string assetTag]/workorders(@http:Payload WorkOrder newWorkOrder) returns WorkOrder|http:NotFound {
        Asset? assetOpt = assetDatabase[assetTag];
        if (assetOpt is ()) {
            return http:NOT_FOUND;
        }
        
        Asset asset = assetOpt;
        asset.workOrders[newWorkOrder.workOrderId] = newWorkOrder;
        assetDatabase.put(asset);
        return newWorkOrder;
    }

    // Update work order
    resource function put assets/[string assetTag]/workorders/[string workOrderId](@http:Payload WorkOrder updatedWorkOrder) returns WorkOrder|http:NotFound {
        Asset? assetOpt = assetDatabase[assetTag];
        if (assetOpt is ()) {
            return http:NOT_FOUND;
        }
        
        Asset asset = assetOpt;
        WorkOrder? workOrderOpt = asset.workOrders[workOrderId];
        if (workOrderOpt is ()) {
            return http:NOT_FOUND;
        }
        
        asset.workOrders[workOrderId] = updatedWorkOrder;
        assetDatabase.put(asset);
        return updatedWorkOrder;
    }

    // Task Management
    
    // Add task to work order
    resource function post assets/[string assetTag]/workorders/[string workOrderId]/tasks(@http:Payload Task newTask) returns Task|http:NotFound {
        Asset? assetOpt = assetDatabase[assetTag];
        if (assetOpt is ()) {
            return http:NOT_FOUND;
        }
        
        Asset asset = assetOpt;
        WorkOrder? workOrderOpt = asset.workOrders[workOrderId];
        if (workOrderOpt is ()) {
            return http:NOT_FOUND;
        }
        
        WorkOrder workOrder = workOrderOpt;
        workOrder.tasks.push(newTask);
        asset.workOrders[workOrderId] = workOrder;
        assetDatabase.put(asset);
        return newTask;
    }

    // Remove task from work order
    resource function delete assets/[string assetTag]/workorders/[string workOrderId]/tasks/[string taskId]() returns Task|http:NotFound {
        Asset? assetOpt = assetDatabase[assetTag];
        if (assetOpt is ()) {
            return http:NOT_FOUND;
        }
        
        Asset asset = assetOpt;
        WorkOrder? workOrderOpt = asset.workOrders[workOrderId];
        if (workOrderOpt is ()) {
            return http:NOT_FOUND;
        }
        
        WorkOrder workOrder = workOrderOpt;
        Task? removedTask = ();
        Task[] newTasks = [];
        
        foreach Task task in workOrder.tasks {
            if (task.taskId == taskId) {
                removedTask = task;
            } else {
                newTasks.push(task);
            }
        }
        
        if (removedTask is ()) {
            return http:NOT_FOUND;
        }
        
        workOrder.tasks = newTasks;
        asset.workOrders[workOrderId] = workOrder;
        assetDatabase.put(asset);
        return removedTask;
    }
}
