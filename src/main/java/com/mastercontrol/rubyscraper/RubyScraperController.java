package com.mastercontrol.rubyscraper;

import lombok.Getter;
import lombok.Setter;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Getter
@Setter
@RestController
@CrossOrigin("*")
public class RubyScraperController {

    @CrossOrigin("*")
    @GetMapping("/keywords/{keywordOne}/{keywordTwo}/{validation}/{functional}/{testPaths}")
    public List<String> rubyScraper(@PathVariable ("keywordOne") String keywordOne,
                                    @PathVariable ("keywordTwo") String keywordTwo,
                                    @PathVariable ("validation") String validationString,
                                    @PathVariable ("functional") String functionalString,
                                    @PathVariable ("testPaths") String testPathsString) {

        boolean validation;
        boolean functional;
        boolean testPaths;

        if(validationString.contains("false")) {
            validation = false;
        } else {
            validation = true;
        }
        if(functionalString.contains("false")) {
            functional = false;
        } else {
            functional = true;
        }
        if(testPathsString.contains("true")) {
            testPaths = true;
        } else {
            testPaths = false;
        }
        List<String> results = RubyScraperService.scrapeTests(keywordOne, keywordTwo, validation, functional, testPaths);
        return results;
    }
}
