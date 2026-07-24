package Listener;

import Model.BookingDAO;
import Controller.customer.BookingFlowSupport;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebListener
public class BookingExpirationListener implements ServletContextListener {

    private ScheduledExecutorService scheduler;
    private static final Logger LOGGER = Logger.getLogger(BookingExpirationListener.class.getName());

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor(runnable -> {
            Thread thread = new Thread(runnable, "BookingExpirationScheduler");
            thread.setDaemon(true);
            return thread;
        });

        // Run every 1 minute to check for expired bookings (created older than 10 minutes)
        scheduler.scheduleAtFixedRate(() -> {
            try (BookingDAO bookingDAO = new BookingDAO()) {
                int released = bookingDAO.releaseExpiredPendingPaymentBookings(BookingFlowSupport.PAYMENT_HOLD_MINUTES);
                if (released > 0) {
                    LOGGER.log(Level.INFO, "Auto-released {0} expired pending payment bookings.", released);
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Error occurred during background release of expired bookings", e);
            }
        }, 1, 1, TimeUnit.MINUTES);

        LOGGER.log(Level.INFO, "BookingExpirationListener initialized. Checking every minute for bookings older than {0} minutes.", BookingFlowSupport.PAYMENT_HOLD_MINUTES);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) {
            scheduler.shutdown();
            try {
                if (!scheduler.awaitTermination(5, TimeUnit.SECONDS)) {
                    scheduler.shutdownNow();
                }
            } catch (InterruptedException ie) {
                scheduler.shutdownNow();
                Thread.currentThread().interrupt();
            }
        }
        LOGGER.log(Level.INFO, "BookingExpirationListener destroyed.");
    }
}
