package tests.customers;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class CustomersRunner {

    @Test
    void test() {
        Results results = Runner.path("classpath:tests/customers")
                .outputCucumberJson(true).parallel(1);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

}
