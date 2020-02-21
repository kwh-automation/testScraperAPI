package com.mastercontrol.rubyscraper;

import com.mastercontrol.rubyscraper.config.RubyScraperConfig;
import org.springframework.stereotype.Service;

import java.io.*;
import java.util.*;


@Service
public class TestFinderService {

    RubyScraper rubyScraper = new RubyScraper();
    RubyScraperConfig rubyScraperConfig = new RubyScraperConfig();

    public List<String> scrapeTests(String key, String secondKey, boolean validation, boolean functional, boolean testPaths) {
        List<String> allResults = new ArrayList<>();
        if(validation) {
            allResults.addAll(getMatchingTestsUsingKeywordAndKeyword(rubyScraperConfig.getPathToValidationFRS(), key, secondKey, testPaths));
        }
        if(functional) {
            allResults.addAll(getMatchingTestsUsingKeywordAndKeyword(rubyScraperConfig.getPathToFunctionalTests(), key, secondKey, testPaths));
        }
        return allResults;
    }

    public List<String> getMatchingTestsUsingKeywordAndKeyword(String pathToTests, String key, String secondKey, boolean returnTestPaths) {
        List<List<String>> scrapedData = rubyScraper.scraper(new File(pathToTests));
        List<String> searchResults = getListUsingKeywordSearchWithOptionalAnd(scrapedData, key.toLowerCase(), secondKey.toLowerCase());
        if(returnTestPaths) {
            return rubyScraper.getFilePathOfMatchingTests(searchResults);
        }
        return searchResults;
    }

    public List<String> getMatchingTestsUsingKeywordOrKeyword(String pathToTests, String key, String secondKey) {
        List<List<String>> scrapedData = rubyScraper.scraper(new File(pathToTests));
        List<String> searchResults = getListUsingKeywordSearchWithOptionalOr(scrapedData, key.toLowerCase(), secondKey.toLowerCase());
        System.out.println(searchResults.size() + " tests found using search term(s): " + key + " AND / OR " +  secondKey + "\n" + searchResults);
        return searchResults;
    }

    public List<String> getListUsingKeywordSearchWithOptionalAnd(List<List<String>> scrapedData, String key, String secondKey) {
        List<String> categoryList = new ArrayList<>();
        for(int i = 0; i < scrapedData.size(); i++) {
            for(int a = 0; a < scrapedData.get(i).size(); a++) {
                if (scrapedData.get(i).get(a).contains(key) && secondKey.isEmpty()) {
                    categoryList.add(scrapedData.get(i).get(0));
                    break;
                }
                else if (scrapedData.get(i).get(a).contains(key)) {
                    for (int count = 0; count < scrapedData.get(i).size(); count++) {
                        if (scrapedData.get(i).get(count).contains(secondKey)) {
                            categoryList.add(scrapedData.get(i).get(0));
                            break;
                        }
                    }
                    break;
                }
            }
        }
        return categoryList;
    }

    public List<String> getListUsingKeywordSearchWithOptionalOr(List<List<String>> scrapedData, String key, String secondKey) {
        List<String> categoryList = new ArrayList<>();
        for(int i = 0; i < scrapedData.size(); i++) {
            for(int a = 0; a < scrapedData.get(i).size(); a++) {
                if (scrapedData.get(i).get(a).contains(key) && secondKey.isEmpty()) {
                    categoryList.add(scrapedData.get(i).get(0));
                    break;
                }
                else if (scrapedData.get(i).get(a).contains(key) || scrapedData.get(i).get(a).contains(secondKey)) {
                    categoryList.add(scrapedData.get(i).get(0));
                    break;
                }
            }
        }
        return categoryList;
    }
}
