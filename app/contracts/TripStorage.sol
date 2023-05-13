// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TripStorage {
    struct Trip {
        uint256 id;
        string pickupLocation;
        string dropOffLocation;
        address payable rider;
        address payable driver;
        bool active;
        bool tripStarted;
        bool completed;
    }

    uint256 public tripId;
    uint256[] public activeTrips;
    mapping(uint256 => Trip) public trips;

    function createTrip(string memory _pickupLocation, string memory _dropOffLocation) public {
        tripId++;
        trips[tripId] = Trip(tripId, _pickupLocation, _dropOffLocation, payable(msg.sender), payable(address(0)), true, false, false);
        activeTrips.push(tripId);
    }

    function selectTrip(uint256 _tripId) public {
        require(trips[_tripId].active, "Trip is not active.");
        trips[_tripId].driver = payable(msg.sender);
        trips[_tripId].active = false;
    }

    function startTrip(uint256 _tripId) public {
        require(trips[_tripId].rider == msg.sender, "Only the assigned rider can start the trip.");
        require(!trips[_tripId].tripStarted, "Trip has already started.");
        trips[_tripId].tripStarted = true;
    }

    function completeTrip(uint256 _tripId) public payable {
        require(trips[_tripId].rider == msg.sender || trips[_tripId].driver == msg.sender, "Only the rider or the driver can complete the trip.");
        require(!trips[_tripId].completed, "Trip has already been completed.");
        trips[_tripId].completed = true;

        // Remove completed trip from the activeTrips array
        for (uint256 i = 0; i < activeTrips.length; i++) {
            if (activeTrips[i] == _tripId) {
                activeTrips[i] = activeTrips[activeTrips.length - 1];
                activeTrips.pop();
                break;
            }
        }
    }

    function getActiveTripCount() public view returns (uint256) {
        return activeTrips.length;
    }
}