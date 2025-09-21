import ballerina/grpc;
import ballerina/protobuf;
import ballerina/protobuf.types.empty;

public const string CAR_RENTAL_DESC = "0A106361725F72656E74616C2E70726F746F120A6361725F72656E74616C1A1B676F6F676C652F70726F746F6275662F656D7074792E70726F746F22B7010A0343617212120A046D616B6518012001280952046D616B6512140A056D6F64656C18022001280952056D6F64656C12120A0479656172180320012805520479656172121E0A0A6461696C795072696365180420012802520A6461696C79507269636512180A076D696C6561676518052001280552076D696C6561676512200A0B6E756D626572506C617465180620012809520B6E756D626572506C61746512160A06737461747573180720012809520673746174757322460A045573657212160A06757365724964180120012809520675736572496412120A046E616D6518022001280952046E616D6512120A04726F6C651803200128095204726F6C6522320A0D4164644361725265717565737412210A0363617218012001280B320F2E6361725F72656E74616C2E436172520363617222260A0E416464436172526573706F6E736512140A0563617249641801200128095205636172496422650A105570646174654361725265717565737412200A0B6E756D626572506C617465180120012809520B6E756D626572506C617465122F0A0A7570646174656443617218022001280B320F2E6361725F72656E74616C2E436172520A7570646174656443617222340A1052656D6F76654361725265717565737412200A0B6E756D626572506C617465180120012809520B6E756D626572506C61746522380A1152656D6F7665436172526573706F6E736512230A046361727318012003280B320F2E6361725F72656E74616C2E43617252046361727322320A184C697374417661696C61626C65436172735265717565737412160A0666696C746572180120012809520666696C74657222340A105365617263684361725265717565737412200A0B6E756D626572506C617465180120012809520B6E756D626572506C61746522500A11536561726368436172526573706F6E736512210A0363617218012001280B320F2E6361725F72656E74616C2E436172520363617212180A076D65737361676518022001280952076D6573736167652284010A10416464546F436172745265717565737412160A06757365724964180120012809520675736572496412200A0B6E756D626572506C617465180220012809520B6E756D626572506C617465121C0A09737461727444617465180320012809520973746172744461746512180A07656E64446174651804200128095207656E64446174652287010A08436172744974656D12200A0B6E756D626572506C617465180120012809520B6E756D626572506C617465121C0A09737461727444617465180220012809520973746172744461746512180A07656E64446174651803200128095207656E644461746512210A0363617218042001280B320F2E6361725F72656E74616C2E436172520363617222310A17506C6163655265736572766174696F6E5265717565737412160A067573657249641801200128095206757365724964228C010A18506C6163655265736572766174696F6E526573706F6E736512240A0D7265736572766174696F6E4964180120012809520D7265736572766174696F6E4964121E0A0A746F74616C5072696365180220012802520A746F74616C5072696365122A0A056974656D7318032003280B32142E6361725F72656E74616C2E436172744974656D52056974656D73222F0A134372656174655573657273526573706F6E736512180A076D65737361676518012001280952076D65737361676532D7040A1043617252656E74616C53657276696365123F0A0641646443617212192E6361725F72656E74616C2E416464436172526571756573741A1A2E6361725F72656E74616C2E416464436172526573706F6E736512420A0B437265617465557365727312102E6361725F72656E74616C2E557365721A1F2E6361725F72656E74616C2E4372656174655573657273526573706F6E73652801123A0A09557064617465436172121C2E6361725F72656E74616C2E557064617465436172526571756573741A0F2E6361725F72656E74616C2E43617212480A0952656D6F7665436172121C2E6361725F72656E74616C2E52656D6F7665436172526571756573741A1D2E6361725F72656E74616C2E52656D6F7665436172526573706F6E7365124C0A114C697374417661696C61626C654361727312242E6361725F72656E74616C2E4C697374417661696C61626C6543617273526571756573741A0F2E6361725F72656E74616C2E436172300112480A09536561726368436172121C2E6361725F72656E74616C2E536561726368436172526571756573741A1D2E6361725F72656E74616C2E536561726368436172526573706F6E736512410A09416464546F43617274121C2E6361725F72656E74616C2E416464546F43617274526571756573741A162E676F6F676C652E70726F746F6275662E456D707479125D0A10506C6163655265736572766174696F6E12232E6361725F72656E74616C2E506C6163655265736572766174696F6E526571756573741A242E6361725F72656E74616C2E506C6163655265736572766174696F6E526573706F6E7365620670726F746F33";

public isolated client class CarRentalServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, CAR_RENTAL_DESC);
    }

    isolated remote function AddCar(AddCarRequest|ContextAddCarRequest req) returns AddCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddCarRequest message;
        if req is ContextAddCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/AddCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddCarResponse>result;
    }

    isolated remote function AddCarContext(AddCarRequest|ContextAddCarRequest req) returns ContextAddCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddCarRequest message;
        if req is ContextAddCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/AddCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddCarResponse>result, headers: respHeaders};
    }

    isolated remote function UpdateCar(UpdateCarRequest|ContextUpdateCarRequest req) returns Car|grpc:Error {
        map<string|string[]> headers = {};
        UpdateCarRequest message;
        if req is ContextUpdateCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/UpdateCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <Car>result;
    }

    isolated remote function UpdateCarContext(UpdateCarRequest|ContextUpdateCarRequest req) returns ContextCar|grpc:Error {
        map<string|string[]> headers = {};
        UpdateCarRequest message;
        if req is ContextUpdateCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/UpdateCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <Car>result, headers: respHeaders};
    }

    isolated remote function RemoveCar(RemoveCarRequest|ContextRemoveCarRequest req) returns RemoveCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemoveCarRequest message;
        if req is ContextRemoveCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/RemoveCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <RemoveCarResponse>result;
    }

    isolated remote function RemoveCarContext(RemoveCarRequest|ContextRemoveCarRequest req) returns ContextRemoveCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemoveCarRequest message;
        if req is ContextRemoveCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/RemoveCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <RemoveCarResponse>result, headers: respHeaders};
    }

    isolated remote function SearchCar(SearchCarRequest|ContextSearchCarRequest req) returns SearchCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchCarRequest message;
        if req is ContextSearchCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/SearchCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <SearchCarResponse>result;
    }

    isolated remote function SearchCarContext(SearchCarRequest|ContextSearchCarRequest req) returns ContextSearchCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchCarRequest message;
        if req is ContextSearchCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/SearchCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <SearchCarResponse>result, headers: respHeaders};
    }

    isolated remote function AddToCart(AddToCartRequest|ContextAddToCartRequest req) returns grpc:Error? {
        map<string|string[]> headers = {};
        AddToCartRequest message;
        if req is ContextAddToCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        _ = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/AddToCart", message, headers);
    }

    isolated remote function AddToCartContext(AddToCartRequest|ContextAddToCartRequest req) returns empty:ContextNil|grpc:Error {
        map<string|string[]> headers = {};
        AddToCartRequest message;
        if req is ContextAddToCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/AddToCart", message, headers);
        [anydata, map<string|string[]>] [_, respHeaders] = payload;
        return {headers: respHeaders};
    }

    isolated remote function PlaceReservation(PlaceReservationRequest|ContextPlaceReservationRequest req) returns PlaceReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        PlaceReservationRequest message;
        if req is ContextPlaceReservationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/PlaceReservation", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <PlaceReservationResponse>result;
    }

    isolated remote function PlaceReservationContext(PlaceReservationRequest|ContextPlaceReservationRequest req) returns ContextPlaceReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        PlaceReservationRequest message;
        if req is ContextPlaceReservationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/PlaceReservation", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <PlaceReservationResponse>result, headers: respHeaders};
    }

    isolated remote function CreateUsers() returns CreateUsersStreamingClient|grpc:Error {
        grpc:StreamingClient sClient = check self.grpcClient->executeClientStreaming("car_rental.CarRentalService/CreateUsers");
        return new CreateUsersStreamingClient(sClient);
    }

    isolated remote function ListAvailableCars(ListAvailableCarsRequest|ContextListAvailableCarsRequest req) returns stream<Car, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailableCarsRequest message;
        if req is ContextListAvailableCarsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("car_rental.CarRentalService/ListAvailableCars", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        CarStream outputStream = new CarStream(result);
        return new stream<Car, grpc:Error?>(outputStream);
    }

    isolated remote function ListAvailableCarsContext(ListAvailableCarsRequest|ContextListAvailableCarsRequest req) returns ContextCarStream|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailableCarsRequest message;
        if req is ContextListAvailableCarsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("car_rental.CarRentalService/ListAvailableCars", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        CarStream outputStream = new CarStream(result);
        return {content: new stream<Car, grpc:Error?>(outputStream), headers: respHeaders};
    }
}

public isolated client class CreateUsersStreamingClient {
    private final grpc:StreamingClient sClient;

    isolated function init(grpc:StreamingClient sClient) {
        self.sClient = sClient;
    }

    isolated remote function sendUser(User message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function sendContextUser(ContextUser message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function receiveCreateUsersResponse() returns CreateUsersResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, _] = response;
            return <CreateUsersResponse>payload;
        }
    }

    isolated remote function receiveContextCreateUsersResponse() returns ContextCreateUsersResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, headers] = response;
            return {content: <CreateUsersResponse>payload, headers: headers};
        }
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.sClient->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.sClient->complete();
    }
}

public class CarStream {
    private stream<anydata, grpc:Error?> anydataStream;

    public isolated function init(stream<anydata, grpc:Error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|Car value;|}|grpc:Error? {
        var streamValue = self.anydataStream.next();
        if streamValue is () {
            return streamValue;
        } else if streamValue is grpc:Error {
            return streamValue;
        } else {
            record {|Car value;|} nextRecord = {value: <Car>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns grpc:Error? {
        return self.anydataStream.close();
    }
}

public isolated client class CarRentalServiceRemoveCarResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendRemoveCarResponse(RemoveCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextRemoveCarResponse(ContextRemoveCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}