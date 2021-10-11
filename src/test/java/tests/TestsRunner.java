package tests;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class TestsRunner {

    @Test
    void runAllFeatures() {
        Results results = Runner.path("classpath:tests")
                .outputCucumberJson(true).parallel(1);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

}
