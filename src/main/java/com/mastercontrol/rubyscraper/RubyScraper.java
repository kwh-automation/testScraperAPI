package com.mastercontrol.rubyscraper;

import com.mastercontrol.rubyscraper.config.RubyScraperConfig;
import com.mastercontrol.rubyscraper.utils.LocalFileUtils;
import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class RubyScraper {

    RubyScraperConfig rubyScraperConfig = new RubyScraperConfig();
    LocalFileUtils localFileUtils = new LocalFileUtils();

    public List<String> getFilePathOfMatchingTests(List<TestData> searchResults) {
        List<String> testPathsAsString = new ArrayList<>();
        List<File> testFilePaths = new ArrayList<>();
        testFilePaths.addAll(getFilePath(new File((rubyScraperConfig.getPathToValidationFRS()))));
        testFilePaths.addAll(getFilePath(new File((rubyScraperConfig.getPathToFunctionalTests()))));
        testPathsAsString.addAll(getFilePathsFromSearchResults(testFilePaths, searchResults));
        return testPathsAsString;
    }

    public List<String> getFilePathsFromSearchResults(List<File> filePaths, List<TestData> searchResults) {
        List<String> testPaths = new ArrayList<>();
        for(File file: filePaths) {
            for(TestData data: searchResults) {
                if(file.toString().contains((data.testName))) {
                    testPaths.add(String.valueOf(file));
                }
            }
        }
        List<String> strippedPaths = localFileUtils.stripAndBuildTestPath(testPaths);
        return strippedPaths;
    }

    public List<TestData> scraper(File path) {
        List<TestData> parsedData = new ArrayList<>();
        localFileUtils.getDirectories(path)
                .stream()
                .forEach(directory -> {
                parsedData.addAll(localFileUtils.getFilesFromDirectory(directory)
                        .stream()
                        .map(file -> readFileToString(new File(String.valueOf(file)))).collect(Collectors.toList()));
        });
         return parsedData;
    }

    public List<File> getFilePath(File path) {
        List<File> parsedData = new ArrayList<>();
        for(File directory : localFileUtils.getDirectories(path)) {
            for (File file: localFileUtils.getFilesFromDirectory(directory)) {
                parsedData.add(getRubyFilePaths(file));
            }
        }
        return parsedData;
    }

    public TestData readFileToString(File rubyFile) {
        TestData data = new TestData();
        data.testName = rubyFile.getName();
        try {
            data.testData = FileUtils.readFileToString(rubyFile, "UTF-8");
            return data;
        } catch (IOException e) {
            e.printStackTrace();
            return data;
        }
    }

    public File getRubyFilePaths(File rubyFile) {
        return new File(rubyFile.getAbsolutePath());
    }
}
