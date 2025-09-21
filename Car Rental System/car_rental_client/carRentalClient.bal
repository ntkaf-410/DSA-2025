import ballerina/io;



// Create a gRPC client to interact with the CarRentalService server
CarRentalServiceClient ep = check new ("http://localhost:9091");

public function main() returns error? {
    io:println("=== Car Rental System Demo ===\n");

    // 1. Create users (streaming)
    io:println("1. Creating users...");
    CreateUsersStreamingClient createUsersClient = check ep->CreateUsers();
    
    // Create admin user
    User admin = {userId: "admin1", name: "John Admin", role: "admin"};
    check createUsersClient->sendUser(admin);
    
    // Create customer users
    User customer1 = {userId: "customer1", name: "Alice Smith", role: "customer"};
    User customer2 = {userId: "customer2", name: "Bob Johnson", role: "customer"};
    check createUsersClient->sendUser(customer1);
    check createUsersClient->sendUser(customer2);
    
    check createUsersClient->complete();
    CreateUsersResponse? createUsersResponse = check createUsersClient->receiveCreateUsersResponse();
    io:println("Users created: ", createUsersResponse?.message);
    io:println();

    // 2. Add cars (Admin operation)
    io:println("2. Adding cars to inventory...");
    
    // Add first car
    AddCarRequest addCarReq1 = {
        car: {
            make: "Toyota",
            model: "Camry",
            year: 2023,
            dailyPrice: 45.00,
            mileage: 15000,
            numberPlate: "ABC123",
            status: "AVAILABLE"
        }
    };
    AddCarResponse addCarResp1 = check ep->AddCar(addCarReq1);
    io:println("Added car: ", addCarResp1.carId);

    // Add second car
    AddCarRequest addCarReq2 = {
        car: {
            make: "Honda",
            model: "Civic",
            year: 2022,
            dailyPrice: 40.00,
            mileage: 25000,
            numberPlate: "XYZ789",
            status: "AVAILABLE"
        }
    };
    AddCarResponse addCarResp2 = check ep->AddCar(addCarReq2);
    io:println("Added car: ", addCarResp2.carId);

    // Add third car
    AddCarRequest addCarReq3 = {
        car: {
            make: "BMW",
            model: "X5",
            year: 2023,
            dailyPrice: 85.00,
            mileage: 8000,
            numberPlate: "BMW001",
            status: "AVAILABLE"
        }
    };
    AddCarResponse addCarResp3 = check ep->AddCar(addCarReq3);
    io:println("Added car: ", addCarResp3.carId);
    io:println();

    // 3. List available cars
    io:println("3. Listing all available cars...");
    ListAvailableCarsRequest listReq = {filter: ""};
    stream<Car, error?> carStream = check ep->ListAvailableCars(listReq);
    
    check from Car car in carStream
        do {
            io:println(string `${car.make} ${car.model} (${car.year}) - $${car.dailyPrice}/day - Plate: ${car.numberPlate}`);
        };
    io:println();

    // 4. Search for a specific car
    io:println("4. Searching for car with plate 'ABC123'...");
    SearchCarRequest searchReq = {numberPlate: "ABC123"};
    SearchCarResponse searchResp = check ep->SearchCar(searchReq);
    io:println("Found: ", searchResp.car.make, " ", searchResp.car.model);
    io:println("Message: ", searchResp.message);
    io:println();

    // 5. Update a car (Admin operation)
    io:println("5. Updating car price...");
    UpdateCarRequest updateReq = {
        numberPlate: "ABC123",
        updatedCar: {
            make: "Toyota",
            model: "Camry",
            year: 2023,
            dailyPrice: 50.00, // Updated price
            mileage: 15000,
            numberPlate: "ABC123",
            status: "AVAILABLE"
        }
    };
    Car updatedCar = check ep->UpdateCar(updateReq);
    io:println("Updated car price to: $", updatedCar.dailyPrice);
    io:println();

    // 6. Add cars to cart
    io:println("6. Adding cars to customer cart...");
    
    AddToCartRequest cartReq1 = {
        userId: "customer1",
        numberPlate: "ABC123",
        startDate: "2025-10-01",
        endDate: "2025-10-05"
    };
    check ep->AddToCart(cartReq1);
    io:println("Added Toyota Camry to customer1's cart");

    AddToCartRequest cartReq2 = {
        userId: "customer1",
        numberPlate: "XYZ789",
        startDate: "2025-10-10",
        endDate: "2025-10-12"
    };
    check ep->AddToCart(cartReq2);
    io:println("Added Honda Civic to customer1's cart");
    io:println();

    // 7. Place reservation
    io:println("7. Placing reservation...");
    PlaceReservationRequest reservationReq = {userId: "customer1"};
    PlaceReservationResponse reservationResp = check ep->PlaceReservation(reservationReq);
    
    io:println("Reservation ID: ", reservationResp.reservationId);
    io:println("Total Price: $", reservationResp.totalPrice);
    io:println("Reserved cars:");
    foreach CartItem item in reservationResp.items {
        io:println("  - ", item.car.make, " ", item.car.model, " (", item.startDate, " to ", item.endDate, ")");
    }
    io:println();

    // 8. Filter cars by make
    io:println("8. Filtering cars by 'Toyota'...");
    ListAvailableCarsRequest filterReq = {filter: "toyota"};
    stream<Car, error?> filteredStream = check ep->ListAvailableCars(filterReq);
    
    check from Car car in filteredStream
        do {
            io:println("Filtered: ", car.make, " ", car.model);
        };
    io:println();

    // 9. Remove a car (Admin operation)
    io:println("9. Removing a car from inventory...");
    RemoveCarRequest removeReq = {numberPlate: "BMW001"};
    RemoveCarResponse removeResp = check ep->RemoveCar(removeReq);
    io:println("Car removed. Remaining cars: ", removeResp.cars.length());
    io:println();

    // 10. Try to search for removed car
    io:println("10. Searching for removed car...");
    SearchCarRequest searchRemovedReq = {numberPlate: "BMW001"};
    SearchCarResponse|error searchResult = ep->SearchCar(searchRemovedReq);
    if searchResult is error {
        io:println("Expected error: ", searchResult.message());
    }

    io:println("\n=== Demo completed successfully! ===");
}