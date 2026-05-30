package Utils;

import Entities.Booking;
import Entities.BookingParticipant;
import Entities.Tour;
import Entities.TourSchedule;
import Entities.User;
import Entities.UserProfile;
import Model.BookingDAO;
import Model.TourDAO;
import Model.UserDAO;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

public class TestModel {
    public static void main(String[] args) {
        System.out.println("========== TOURBUDDY INTEGRATION TESTING ==========");
        
        UserDAO userDAO = new UserDAO();
        TourDAO tourDAO = new TourDAO();
        BookingDAO bookingDAO = new BookingDAO();

        String testEmail = "test_" + System.currentTimeMillis() + "@tourbuddy.com";
        String testPasswordHash = "hashed_pwd_123456";
        int testRoleId = 4; // Customer role ID from seed data

        // 1. Test User Registration
        System.out.println("\n[STEP 1] Testing User Registration...");
        User newUser = new User();
        newUser.setEmail(testEmail);
        newUser.setPasswordHash(testPasswordHash);
        newUser.setFullName("Nguyen Van Test");
        newUser.setPhoneNumber("0987654321");
        newUser.setRoleId(testRoleId);

        UserProfile profile = new UserProfile();
        profile.setAvatarUrl("https://example.com/avatar.jpg");
        profile.setBiography("I love hiking and beaches!");
        profile.setDateOfBirth(Date.valueOf("2000-01-01"));
        profile.setGender("Male");
        profile.setAddress("123 Test Street, Hanoi");
        profile.setTravelInterests("Beach, Trekking");

        boolean regSuccess = userDAO.register(newUser, profile);
        if (regSuccess) {
            System.out.println("   -> User registered successfully! ✅");
        } else {
            System.out.println("   -> User registration FAILED! ❌");
            return;
        }

        // 2. Test User Login
        System.out.println("\n[STEP 2] Testing User Login...");
        User loggedUser = userDAO.login(testEmail, testPasswordHash);
        if (loggedUser != null) {
            System.out.println("   -> Login success! Welcome " + loggedUser.getFullName() + " (ID: " + loggedUser.getUserId() + ") ✅");
            if (loggedUser.getProfile() == null) {
                // Fetch full details
                loggedUser = userDAO.getUserById(loggedUser.getUserId());
            }
            if (loggedUser.getProfile() != null) {
                System.out.println("      * Profile biography: " + loggedUser.getProfile().getBiography());
            } else {
                System.out.println("      * Profile NOT found! ❌");
            }
        } else {
            System.out.println("   -> Login FAILED! ❌");
            return;
        }

        // 3. Browse Tours & Select Schedule
        System.out.println("\n[STEP 3] Browsing Tours & Selecting Schedule...");
        List<Tour> tours = tourDAO.searchTours(null, null, null, null);
        if (tours.isEmpty()) {
            System.out.println("   -> No tours found! ❌");
            return;
        }

        Tour selectedTour = null;
        TourSchedule selectedSchedule = null;

        for (Tour t : tours) {
            Tour detail = tourDAO.getTourById(t.getTourId());
            if (detail.getSchedules() != null && !detail.getSchedules().isEmpty()) {
                selectedTour = detail;
                selectedSchedule = detail.getSchedules().get(0);
                break;
            }
        }

        if (selectedTour == null || selectedSchedule == null) {
            System.out.println("   -> No tours with active schedules found in DB.");
            System.out.println("   -> Creating a mock schedule dynamically in SQL...");
            // Let's create a schedule dynamically so we can test booking
            int tourId = tours.get(0).getTourId();
            String insertScheduleSql = "INSERT INTO TourSchedule (TourID, DepartureDate, ReturnDate, TotalSeats, AvailableSeats, PriceAdult, PriceChild, PriceInfant, Status) "
                                     + "VALUES (" + tourId + ", DATEADD(day, 10, GETDATE()), DATEADD(day, 13, GETDATE()), 20, 20, 3000000, 1500000, 500000, 'Open')";
            try (java.sql.Statement stmt = userDAO.getConnection().createStatement()) {
                stmt.executeUpdate(insertScheduleSql, java.sql.Statement.RETURN_GENERATED_KEYS);
                try (java.sql.ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        int generatedScheduleId = rs.getInt(1);
                        System.out.println("   -> Created mock schedule with ID: " + generatedScheduleId);
                    }
                }
            } catch (java.sql.SQLException ex) {
                System.out.println("   -> Failed to insert mock schedule: " + ex.getMessage() + " ❌");
                return;
            }
            
            // Fetch schedules again
            selectedTour = tourDAO.getTourById(tourId);
            selectedSchedule = selectedTour.getSchedules().get(0);
        }

        System.out.println("   -> Selected Tour: " + selectedTour.getTourName());
        System.out.println("   -> Selected Schedule ID: " + selectedSchedule.getScheduleId() + " (Departure: " + selectedSchedule.getDepartureDate() + ")");
        System.out.println("   -> Available Seats BEFORE Booking: " + selectedSchedule.getAvailableSeats());

        // 4. Create Booking
        System.out.println("\n[STEP 4] Testing Booking creation & Seat reservation...");
        int bookingSeats = 3;
        String bCode = "TB-" + (100000 + (int)(Math.random() * 900000));
        
        Booking booking = new Booking();
        booking.setBookingCode(bCode);
        booking.setCustomerId(loggedUser.getUserId());
        booking.setScheduleId(selectedSchedule.getScheduleId());
        booking.setNumParticipants(bookingSeats);
        booking.setBaseAmount(selectedSchedule.getPriceAdult() * bookingSeats);
        booking.setTotalAmount(selectedSchedule.getPriceAdult() * bookingSeats);
        booking.setStatus("PendingPayment");
        booking.setNotes("Integration test booking");

        List<BookingParticipant> participants = new ArrayList<>();
        // Leader
        BookingParticipant leader = new BookingParticipant();
        leader.setFullName(loggedUser.getFullName());
        leader.setAgeType("Adult");
        leader.setPhoneNumber(loggedUser.getPhoneNumber());
        leader.setEmail(loggedUser.getEmail());
        leader.setIsLeader(true);
        participants.add(leader);

        // Guest 1
        BookingParticipant guest1 = new BookingParticipant();
        guest1.setFullName("Nguyen Van Guest A");
        guest1.setAgeType("Adult");
        participants.add(guest1);

        // Guest 2
        BookingParticipant guest2 = new BookingParticipant();
        guest2.setFullName("Nguyen Van Guest B");
        guest2.setAgeType("Child");
        participants.add(guest2);

        booking.setParticipants(participants);

        boolean bookSuccess = bookingDAO.createBooking(booking);
        if (bookSuccess) {
            System.out.println("   -> Booking " + bCode + " created successfully! ✅");
        } else {
            System.out.println("   -> Booking creation FAILED! ❌");
            return;
        }

        // 5. Verify Seat Reservation
        System.out.println("\n[STEP 5] Verifying Seat Reservation...");
        Tour updatedTour = tourDAO.getTourById(selectedTour.getTourId());
        TourSchedule updatedSchedule = null;
        for (TourSchedule s : updatedTour.getSchedules()) {
            if (s.getScheduleId() == selectedSchedule.getScheduleId()) {
                updatedSchedule = s;
                break;
            }
        }
        
        if (updatedSchedule != null) {
            System.out.println("   -> Available Seats AFTER Booking: " + updatedSchedule.getAvailableSeats());
            int expectedSeats = selectedSchedule.getAvailableSeats() - bookingSeats;
            if (updatedSchedule.getAvailableSeats() == expectedSeats) {
                System.out.println("   -> Available seats decremented correctly! (Expected: " + expectedSeats + ", Got: " + updatedSchedule.getAvailableSeats() + ") ✅");
            } else {
                System.out.println("   -> Available seats mismatch! ❌");
            }
        } else {
            System.out.println("   -> Schedule not found after booking! ❌");
        }

        // 6. Retrieve and Verify Booking Details
        System.out.println("\n[STEP 6] Retrieving Booking Details by Code...");
        Booking retrievedBooking = bookingDAO.getBookingByCode(bCode);
        if (retrievedBooking != null) {
            System.out.println("   -> Successfully retrieved booking " + retrievedBooking.getBookingCode() + "! ✅");
            System.out.println("   -> Total amount: " + retrievedBooking.getTotalAmount());
            System.out.println("   -> Number of participants retrieved: " + retrievedBooking.getParticipants().size());
            for (BookingParticipant p : retrievedBooking.getParticipants()) {
                System.out.println("      * " + p.getFullName() + " (" + p.getAgeType() + ")" + (p.isIsLeader() ? " [Leader]" : ""));
            }
        } else {
            System.out.println("   -> Failed to retrieve booking! ❌");
        }

        System.out.println("\n================ INTEGRATION TESTING COMPLETED ================");
    }
}
