package com.mastercontrol.rubyscraper;

import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RubyFile {
    private String fileName;
    private List<String> methodNames;
}
