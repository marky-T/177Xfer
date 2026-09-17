package <PACKAGE>;

import com.avanade.ltcoe.amt.common.config.database.SysDatabaseConfig;
import com.avanade.ltcoe.amt.common.config.database.TransactionDatabaseConfig;
import com.avanade.ltcoe.amt.common.logging.LogMessage;
import com.avanade.ltcoe.amt.common.logging.Logger;
import com.avanade.ltcoe.amt.platform.AMTRuntime;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;

/**
 * Main class of the Application using the AMT GO Pekko edition.
 */
@SpringBootApplication()
@Import({
        SysDatabaseConfig.class,
        TransactionDatabaseConfig.class
})
public class AmtApplication {
    private static final Logger LOGGER = Logger.getLogger(AmtApplication.class);

    /**
     * Main method starting the Application using the AMT GO Pekko edition.
     *
     * @param args the command line arguments.
     */
    public static void main(String[] args) {
        // Configure the AMT Runtime
        AMTRuntime.configureApplication(args);

        // Boot the Spring Application
        new SpringApplicationBuilder(AmtApplication.class)
                .build(args)
                .run();
    }

    @Bean
    public CommandLineRunner commandLineRunner(ApplicationContext ctx) {
        return args -> {
            try {
                AMTRuntime.startApplication(ctx);
            } catch (Exception e) {
                LOGGER.error(LogMessage.START_SYSTEM_FAILED, e, e.getMessage());
                // Wait 3 seconds to let the logger flush the error messages.
                Thread.sleep(3000);
                // Then terminate the JVM
                System.exit(1);
            }
        };
    }
}
