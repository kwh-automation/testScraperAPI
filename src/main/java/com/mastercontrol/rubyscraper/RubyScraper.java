package com.mastercontrol.rubyscraper;

import com.mastercontrol.rubyscraper.config.RubyScraperConfig;
import com.mastercontrol.rubyscraper.utils.LocalFileUtils;
import lombok.val;
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
        List<File> validationPaths = getFilePath(new File((rubyScraperConfig.getPathToValidationFRS())));
        List<File> functionalPaths = getFilePath(new File((rubyScraperConfig.getPathToFunctionalTests())));
        List<String> allTestPaths = new ArrayList<>();
        allTestPaths.addAll(getFilePathsFromSearchResults(validationPaths, functionalPaths, searchResults));
        return allTestPaths;
    }

    public List<String> getFilePathsFromSearchResults(List<File> functionalFilePaths, List<File> validationFilePaths, List<TestData> searchResults) {
        List<String> testPaths = new ArrayList<>();
        List<File> compiledPaths = new ArrayList<>();
        compiledPaths.addAll(functionalFilePaths);
        compiledPaths.addAll(validationFilePaths);

        for(int i = 0; i < compiledPaths.size(); i++) {
            for(int n = 0; n < searchResults.size(); n++) {
                if((String.valueOf(compiledPaths.get(i)).contains((searchResults.get(n).testData)))) {
                    testPaths.add(String.valueOf(compiledPaths.get(i)));
                }
            }
        }

        List<String> strippedPaths = localFileUtils.stripAndBuildTestPath(testPaths);
        return strippedPaths;
    }

    public List<TestData> scraper(File path) {
        List<File> directories = localFileUtils.getDirectories(path);
        List<TestData> parsedData = new ArrayList<>();
        /*directories.stream()
                    .forEach(directory -> localFileUtils.getFilesFromDirectory(directory)
                    .stream()
                    .forEach(file -> parsedData.add(readFileToString(new File(String.valueOf(file))))));*/

        directories.stream().forEach(directory -> {
                parsedData.addAll(localFileUtils.getFilesFromDirectory(directory).stream()
                    .map(file -> readFileToString(new File(String.valueOf(file)))).collect(Collectors.toList()));
        });
        /*directories.stream()
                .forEach(directory -> localFileUtils.getFilesFromDirectory(directory)
                        .stream()
                        .map(file -> this::readFileToString(new File(String.valueOf(file)))))*/
                        //.forEach(file -> parsedData.add(readFileToString(new File(String.valueOf(file))))));

         return parsedData;
    }

    public List<File> getFilePath(File path) {
        List<File> parsedData = new ArrayList<>();
        List<File> directories = localFileUtils.getDirectories(path);

        for(File directory : directories) {
            List<File> filesToBeParsed = localFileUtils.getFilesFromDirectory(directory);
            for (int i = 0; i < filesToBeParsed.size(); i++) {
                parsedData.addAll(scrapeFileDataForPath(filesToBeParsed.get(i)));
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

    public List<File> getRubyFilePaths(File rubyFile) {
        List<File> filePaths = new ArrayList<>();
        filePaths.add(new File(rubyFile.getAbsolutePath()));
        return filePaths;
    }

    public List<File> scrapeFileDataForPath(File rubyFile) {
        return getRubyFilePaths(rubyFile);
    }
}
