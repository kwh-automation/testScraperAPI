package com.mastercontrol.rubyscraper;

import com.mastercontrol.rubyscraper.config.RubyScraperConfig;
import org.springframework.stereotype.Service;

import java.io.*;
import java.util.*;


@Service
public class TestFinderService {

    RubyScraper rubyScraper = new RubyScraper();
    RubyScraperConfig rubyScraperConfig = new RubyScraperConfig();
    TestData testData = new TestData();

    public List<String> scrapeTests(String key, String secondKey, boolean validation, boolean functional, boolean testPaths) {
        List<TestData> allResults = new ArrayList<>();
        if(validation) {
            allResults.addAll(getMatchingTestsUsingKeywordAndKeyword(rubyScraperConfig.getPathToValidationFRS(), key, secondKey));
        }
        if(functional) {
            allResults.addAll(getMatchingTestsUsingKeywordAndKeyword(rubyScraperConfig.getPathToFunctionalTests(), key, secondKey));
        }
        if(testPaths) {
            return rubyScraper.getFilePathOfMatchingTests(allResults);
        }
        return testData.getTestNamesAsStringList(allResults);
    }

    public List<TestData> getMatchingTestsUsingKeywordAndKeyword(String pathToTests, String key, String secondKey) {
        List<TestData> scrapedData = rubyScraper.scraper(new File(pathToTests));
        List<TestData> searchResults = getListUsingKeywordSearchWithOptionalAnd(scrapedData, key.toLowerCase(), secondKey.toLowerCase());
        return searchResults;
    }

    //Possible that this might be used in a later iteration
    public List<TestData> getMatchingTestsUsingKeywordOrKeyword(String pathToTests, String key, String secondKey) {
        List<TestData> scrapedData = rubyScraper.scraper(new File(pathToTests));
        List<TestData> searchResults = getListUsingKeywordSearchWithOptionalOr(scrapedData, key.toLowerCase(), secondKey.toLowerCase());
        System.out.println(searchResults.size() + " tests found using search term(s): " + key + " AND / OR " +  secondKey + "\n" + searchResults);
        return searchResults;
    }

    public List<TestData> getListUsingKeywordSearchWithOptionalAnd(List<TestData> scrapedData, String key, String secondKey) {
        List<TestData> keywordSearchResults = new ArrayList<>();
        for(TestData dataList: scrapedData) {
            if (secondKey.isEmpty() && dataList.testData.contains(key)
                || dataList.testData.contains(key) && dataList.testData.contains(secondKey)) {
                keywordSearchResults.add(dataList);
            }
        }
        return keywordSearchResults;
    }

    public List<TestData> getListUsingKeywordSearchWithOptionalOr(List<TestData> scrapedData, String key, String secondKey) {
        List<TestData> keywordSearchResults = new ArrayList<>();
        for (TestData dataList : scrapedData) {
            if (dataList.testData.contains(key) || dataList.testData.contains(secondKey)) {
                keywordSearchResults.add(dataList);
            }
        }
        return keywordSearchResults;
    }
}
