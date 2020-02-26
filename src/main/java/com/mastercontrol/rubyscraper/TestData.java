package com.mastercontrol.rubyscraper;

import java.util.ArrayList;
import java.util.List;

public class TestData {
    String testName;
    String testData;

    public List<String> getTestNamesAsStringList(List<TestData> results) {
        List<String> testNamesToString = new ArrayList<>();
        for(TestData nameData: results) {
            testNamesToString.add(nameData.testName);
        }
        return testNamesToString;
    }
}
