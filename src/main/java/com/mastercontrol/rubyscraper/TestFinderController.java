package com.mastercontrol.rubyscraper;

import lombok.Getter;
import lombok.Setter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Getter
@Setter
@RestController
@CrossOrigin("*")
public class TestFinderController {
    @Autowired
    TestFinderService testFinderService;

    @CrossOrigin("*")
    @GetMapping("/keywords/{keywordOne}/{keywordTwo}/{validation}/{functional}/{testPaths}")
    public List<String> rubyScraper(@PathVariable ("keywordOne") String keywordOne,
                                    @PathVariable ("keywordTwo") String keywordTwo,
                                    @PathVariable ("validation") String validation,
                                    @PathVariable ("functional") String functional,
                                    @PathVariable ("testPaths") String testPath) {

        List<String> results = testFinderService.scrapeTests(keywordOne, keywordTwo, Boolean.valueOf(validation), Boolean.valueOf(functional), Boolean.valueOf(testPath));
        return results;
    }
}
