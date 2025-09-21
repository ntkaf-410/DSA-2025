import ballerina/grpc;
import ballerina/io;
import ballerina/uuid;

// This is imported from generated car_rental_pb.bal file
public const string CAR_RENTAL_DESC = "0A106361725F72656E74616C2E70726F746F120A6361725F72656E74616C1A1B676F6F676C652F70726F746F6275662F656D7074792E70726F746F22B7010A0343617212120A046D616B6518012001280952046D616B6512140A056D6F64656C18022001280952056D6F64656C12120A0479656172180320012805520479656172121E0A0A6461696C795072696365180420012802520A6461696C79507269636512180A076D696C6561676518052001280552076D696C6561676512200A0B6E756D626572506C617465180620012809520B6E756D626572506C61746512160A06737461747573180720012809520673746174757322460A045573657212160A06757365724964180120012809520675736572496412120A046E616D6518022001280952046E616D6512120A04726F6C651803200128095204726F6C6522320A0D4164644361725265717565737412210A0363617218012001280B320F2E6361725F72656E74616C2E436172520363617222260A0E416464436172526573706F6E736512140A0563617249641801200128095205636172496422650A105570646174654361725265717565737412200A0B6E756D626572506C617465180120012809520B6E756D626572506C617465122F0A0A7570646174656443617218022001280B320F2E6361725F72656E74616C2E436172520A7570646174656443617222340A1052656D6F76654361725265717565737412200A0B6E756D626572506C617465180120012809520B6E756D626572506C61746522380A1152656D6F7665436172526573706F6E736512230A046361727318012003280B320F2E6361725F72656E74616C2E43617252046361727322320A184C697374417661696C61626C65436172735265717565737412160A0666696C746572180120012809520666696C74657222340A105365617263684361725265717565737412200A0B6E756D626572506C617465180120012809520B6E756D626572506C61746522500A11536561726368436172526573706F6E736512210A0363617218012001280B320F2E6361725F72656E74616C2E436172520363617212180A076D65737361676518022001280952076D6573736167652284010A10416464546F436172745265717565737412160A06757365724964180120012809520675736572496412200A0B6E756D626572506C617465180220012809520B6E756D626572506C617465121C0A09737461727444617465180320012809520973746172744461746512180A07656E64446174651804200128095207656E64446174652287010A08436172744974656D12200A0B6E756D626572506C617465180120012809520B6E756D626572506C617465121C0A09737461727444617465180220012809520973746172744461746512180A07656E64446174651803200128095207656E644461746512210A0363617218042001280B320F2E6361725F72656E74616C2E436172520363617222310A17506C6163655265736572766174696F6E5265717565737412160A067573657249641801200128095206757365724964228C010A18506C6163655265736572766174696F6E526573706F6E736512240A0D7265736572766174696F6E4964180120012809520D7265736572766174696F6E4964121E0A0A746F74616C5072696365180220012802520A746F74616C5072696365122A0A056974656D7318032003280B32142E6361725F72656E74616C2E436172744974656D52056974656D73222F0A134372656174655573657273526573706F6E736512180A076D65737361676518012001280952076D65737361676532D7040A1043617252656E74616C53657276696365123F0A0641646443617212192E6361725F72656E74616C2E416464436172526571756573741A1A2E6361725F72656E74616C2E416464436172526573706F6E736512420A0B437265617465557365727312102E6361725F72656E74616C2E557365721A1F2E6361725F72656E74616C2E4372656174655573657273526573706F6E73652801123A0A09557064617465436172121C2E6361725F72656E74616C2E557064617465436172526571756573741A0F2E6361725F72656E74616C2E43617212480A0952656D6F7665436172121C2E6361725F72656E74616C2E52656D6F7665436172526571756573741A1D2E6361725F72656E74616C2E52656D6F7665436172526573706F6E7365124C0A114C697374417661696C61626C654361727312242E6361725F72656E74616C2E4C697374417661696C61626C6543617273526571756573741A0F2E6361725F72656E74616C2E436172300112480A09536561726368436172121C2E6361725F72656E74616C2E536561726368436172526571756573741A1D2E6361725F72656E74616C2E536561726368436172526573706F6E736512410A09416464546F43617274121C2E6361725F72656E74616C2E416464546F43617274526571756573741A162E676F6F676C652E70726F746F6275662E456D707479125D0A10506C6163655265736572766174696F6E12232E6361725F72656E74616C2E506C6163655265736572766174696F6E526571756573741A242E6361725F72656E74616C2E506C6163655265736572766174696F6E526573706F6E7365620670726F746F33";


// Listener for gRPC service
listener grpc:Listener ep = new (9091);

// Global storage maps
map<Car> cars = {};
map<User> users = {};
map<CartItem[]> userCarts = {}; // userId -> cart items
map<PlaceReservationResponse[]> reservations = {}; // userId -> reservations

// Define the CarRentalService
@grpc:Descriptor {value: CAR_RENTAL_DESC}
service "CarRentalService" on ep {
    
    // Add a new car (Admin only)
    remote function AddCar(AddCarRequest value) returns AddCarResponse|error {
        string plateId = value.car.numberPlate;
        cars[plateId] = value.car;
        io:println("Car added with plate: ", plateId);
        return {carId: plateId}; 
    }

    // Create multiple users via streaming
    remote function CreateUsers(stream<User, grpc:Error?> clientStream) returns CreateUsersResponse|error {
        io:println("Receiving users...");
        User[] receivedUsers = [];

        check from User user in clientStream
            do {
                io:println("Received User: ", user.userId, " - ", user.name);
                receivedUsers.push(user);
                users[user.userId] = user;
                // Initialize empty cart for new users
                userCarts[user.userId] = [];
            };

        return {message: "Successfully created " + receivedUsers.length().toString() + " users."};
    }

    // Update car details (Admin only)
    remote function UpdateCar(UpdateCarRequest value) returns Car|error {
        if cars.hasKey(value.numberPlate) {
            cars[value.numberPlate] = value.updatedCar;
            io:println("Car updated: ", value.numberPlate);
            return value.updatedCar;
        } else {
            return error("Car with plate " + value.numberPlate + " not found.");
        }
    }

    // Remove a car (Admin only)
    remote function RemoveCar(RemoveCarRequest value) returns RemoveCarResponse|error {
        if cars.hasKey(value.numberPlate) {
            _ = cars.remove(value.numberPlate);
            Car[] remainingCars = [];
            foreach var [_, car] in cars.entries() {
                remainingCars.push(car);
            }
            io:println("Car removed: ", value.numberPlate);
            return {cars: remainingCars};
        } else {
            return error("Car with plate " + value.numberPlate + " not found.");
        }
    }

    // List available cars with optional filtering
    remote function ListAvailableCars(ListAvailableCarsRequest value) returns stream<Car, error?>|error {
        Car[] availableCars = [];
        
        foreach var [_, car] in cars.entries() {
            if car.status == "AVAILABLE" {
                // Apply filter if provided
                if value.filter != "" {
                    string filter = value.filter.toLowerAscii();
                    string carInfo = (car.make + " " + car.model + " " + car.year.toString()).toLowerAscii();
                    if carInfo.includes(filter) {
                        availableCars.push(car);
                    }
                } else {
                    availableCars.push(car);
                }
            }
        }
        
        return availableCars.toStream();
    }

    // Search for a specific car by plate
    remote function SearchCar(SearchCarRequest value) returns SearchCarResponse|error {
        Car? car = cars.get(value.numberPlate);
        if car is Car {
            if car.status == "AVAILABLE" {
                return {car: car, message: "Car found and available"};
            } else {
                return {car: car, message: "Car found but not available"};
            }
        } else {
            return error("Car with plate " + value.numberPlate + " not found.");
        }
    }

    // Add car to customer's cart with rental dates
    remote function AddToCart(AddToCartRequest value) returns error? {
        // Check if car exists and is available
        Car? car = cars[value.numberPlate];
        if car is Car {
            if car.status != "AVAILABLE" {
                return error("Car is not available for rental.");
            }

            // Validate dates
            if !isValidDateRange(value.startDate, value.endDate) {
                return error("Invalid date range. End date must be after start date.");
            }

            // Check if user exists
            if !users.hasKey(value.userId) {
                return error("User not found.");
            }

            // Get or initialize user cart
            CartItem[] userCart = userCarts[value.userId] ?: [];
            
            // Check for conflicts with existing cart items
            foreach CartItem item in userCart {
                if item.numberPlate == value.numberPlate {
                    if hasDateOverlap(item.startDate, item.endDate, value.startDate, value.endDate) {
                        return error("Date conflict with existing cart item for the same car.");
                    }
                }
            }

            // Add to cart
            CartItem newItem = {
                numberPlate: value.numberPlate,
                startDate: value.startDate,
                endDate: value.endDate,
                car: car
            };
            userCart.push(newItem);
            userCarts[value.userId] = userCart;

            io:println("Car added to cart for user: ", value.userId);
        } else {
            return error("Car not found.");
        }

        return ();
    }

    // Place reservation from cart items
    remote function PlaceReservation(PlaceReservationRequest value) returns PlaceReservationResponse|error {
        CartItem[]? cart = userCarts.get(value.userId);
        if cart is CartItem[] && cart.length() > 0 {
            // Verify all cars are still available and calculate total price
            float totalPrice = 0.0;
            foreach CartItem item in cart {
                Car? car = cars[item.numberPlate];
                if car is Car && car.status == "AVAILABLE" {
                    int days = calculateDays(item.startDate, item.endDate);
                    totalPrice += car.dailyPrice * <float>days;
                } else {
                    return error("Car " + item.numberPlate + " is no longer available.");
                }
            }

            // Create reservation
            string reservationId = "RES-" + uuid:createType1AsString();
            PlaceReservationResponse reservation = {
                reservationId: reservationId,
                totalPrice: totalPrice,
                items: cart.clone()
            };

            // Store reservation
            PlaceReservationResponse[] userReservations = reservations[value.userId] ?: [];
            userReservations.push(reservation);
            reservations[value.userId] = userReservations;

            // Clear cart
            userCarts[value.userId] = [];

            io:println("Reservation placed: ", reservationId, " for user: ", value.userId);
            return reservation;
        } else {
            return error("No items in cart for user " + value.userId);
        }
    }
}

// Helper functions
function isValidDateRange(string startDate, string endDate) returns boolean {
    // Simple date validation - in production, use proper date parsing
    return startDate < endDate;
}

function hasDateOverlap(string start1, string end1, string start2, string end2) returns boolean {
    // Simple overlap check - in production, use proper date parsing
    return !(end1 < start2 || end2 < start1);
}

function calculateDays(string startDate, string endDate) returns int {
    // Simplified calculation - in production, use proper date parsing
    // For now, return a default of 1 day
    return 1;
}