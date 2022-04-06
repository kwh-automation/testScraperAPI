package com.mastercontrol.rubyscraper.config;

import static com.mastercontrol.rubyscraper.FileUtils.setMyMasterControlRootPath;

public class ScraperConfig {

    public static String masterControlRoot = String.valueOf(setMyMasterControlRootPath("C:\\QA\\"));
    public static String defaultPathToTests = "insert_path";
    public static String testsPath = masterControlRoot + defaultPathToTests;
    public static String pathToValidationFRS = testsPath + "\\validation\\frs";
    public static String pathToFunctionalTests = testsPath + "\\functional";
}
