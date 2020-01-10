package com.mastercontrol.rubyscraper.config;

import static com.mastercontrol.rubyscraper.FileUtils.setMyMasterControlRootPath;

public class ScraperConfig {

    public static String masterControlRoot = String.valueOf(setMyMasterControlRootPath("C:\\QA\\"));
    public static String defaultPathToTests = "\\mastercontrol\\services\\Presentation\\tests\\gems\\mastercontrol-test-suite\\lib\\mastercontrol-test-suite\\tests\\";
    public static String testsPath = masterControlRoot + defaultPathToTests;
    public static String pathToValidationFRS = testsPath + "\\validation\\frs";
    public static String pathToValidationURS = testsPath + "\\validation\\urs";
    public static String pathToFunctionalTests = testsPath + "\\functional";
    public static final String productionRecordsValidation = pathToValidationFRS + "\\production_records";
    public static final String productionRecordsFunctional = pathToFunctionalTests + "\\production_records";
}
