# DSA-2025
Ndina Unandapo 224062476
1.Created Ballerina.toml configuration files
2.Defined all the core record types(Assets,Components,Schedule,Task.WorkOrder)
3.Set up the AssetStatus enumaration
4.Established the main asser database table structure

Atuhe Kambonde 224016172
1.Basic Asset CRUD Operations (Server)
2.Implemented POST /assets (create asset)
3.Implemented GET /assets (view all assets)
4.Implemented GET /assets/[assetTag] (view asset by tag)
5.Implemented PUT /assets/[assetTag] (update asset)
6.Implemented DELETE /assets/[assetTag] (delete asset)

Ndati Kafidi 224066765
1. Implemented GET /assets/faculty to view assets by faculty
2. Implemented GET /assets/overdue to check for any overdue maintenance schedules
3. Created the overdue calculation logic using time comparison
4. Handled date/time parsing and validation

Nao Nakangombe 224026569

1. Added POST /assets/{assetTag}/components to add a component to an asset
2. Added DELETE /assets/{assetTag}/components/{componentId} to remove a component
3. Made components attach to the correct asset (they’re stored under that asset)
4. Saved component information inside the asset data whenever it’s created or updated

Jedidja Mbinga 224016148

1. Added support for creating new schedules using POST, assets, assetTag, and schedules
2. Enabled schedule removal via DELETE, assets,assetTag, schedules, and scheduleId
3. Implemented POST, assets, assetTag, and workorders to create work order
4. Implemented updates to existing work orders through PUT, assets, assetTag, workorders, andworkOrderId`

Petrus Amukugo 224032119

1. Added POST endpoint to create tasks
2. Added DELETE endpoint to remove tasks
3. Added task work order relationship logic
4. Handled nested data operations




