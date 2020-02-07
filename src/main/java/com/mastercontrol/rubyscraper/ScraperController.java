package com.mastercontrol.rubyscraper;

import lombok.Getter;
import lombok.Setter;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Getter
@Setter
@RestController
@CrossOrigin("*")
public class ScraperController {

    @CrossOrigin("*")
    @GetMapping("/keywords/{keywordOne}/{keywordTwo}")
    public List<String> rubyScraper(@PathVariable ("keywordOne") String keywordOne, @PathVariable ("keywordTwo") String keywordTwo) {
        List<String> results = RubyScraper.scrapeTests(keywordOne, keywordTwo, true, true, false);
        return results;
    }
}
